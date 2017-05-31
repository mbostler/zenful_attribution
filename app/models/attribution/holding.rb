# == Schema Information
#
# Table name: attribution_holdings
#
#  id           :integer          not null, primary key
#  company_id   :integer
#  day_id       :integer
#  performance  :float
#  contribution :float
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Attribution::Holding < ApplicationRecord
  include Auditing
  belongs_to :company, class_name: "AxysSystem::Company"
  belongs_to :day, class_name: "Attribution::Day"
  
  has_one :bmv_axys_holding, nil, foreign_key: :bmv_holding_id, class_name: "AxysSystem::Holding", dependent: :nullify
  has_one :emv_axys_holding, nil, foreign_key: :emv_holding_id, class_name: "AxysSystem::Holding", dependent: :nullify
  has_many :transactions, foreign_key: :holding_id, class_name: "AxysSystem::Transaction", dependent: :nullify
  
  def axys_holding=(axys_holding)
    self.company_id = axys_holding.company_id
  end
  
  after_create :perform_after_create_actions
  
  def perform_after_create_actions
    associate_axys_records
  end
  
  def update_calcs
    puts "### updating calcs for #{company.tag} on #{date}"
    update_performance
    update_contribution
    puts "### successfully updated calcs for #{company.tag} on #{date}"
  end
  
  def update_performance
    update_attribute :performance, performance_value
  end
  
  def update_contribution
    update_attribute :contribution, contribution_value
  end

  def associate_axys_records
    associate_axys_holdings
    associate_axys_transactions
  end
  
  def associate_axys_holdings
    h = axys_portfolio.holdings.where( date: day.date, company_id: company_id ).first
    h.update_attribute( :emv_holding_id, self.id ) if h

    ph = axys_portfolio.holdings.where( date: day.date.prev_reportable_day, company_id: company_id ).first
    ph.update_attribute( :bmv_holding_id, self.id ) if ph
  end
  
  def associate_axys_transactions
    date_range = (day.date.prev_reportable_day+1..day.date)
    txns = axys_portfolio.transactions.where( date: date_range, company_id: company_id )
    txns.each { |txn| txn.update_attribute( :holding_id, self.id) }
  end
  
  def axys_portfolio
    day and day.axys_portfolio
  end
  
  def emv_value
    if emv_axys_holding
      emv_axys_holding.market_value
    else
      0
    end
  end

  def bmv_value
    if bmv_axys_holding
      bmv_axys_holding.market_value
    else
      0
    end
  end
  
  def txns_value
    purchases_value - sales_value - income_value
  end
  
  # def txns_without_flows_value
  #   purchases_without_flows_value - sales_without_flows_value - income_without_flows_value
  # end
  #
  # def purchases_without_flows_value
  #   value_of purchases_without_flows
  # end
  #
  # def sales_without_flows_value
  #   value_of sales_without_flows
  # end
  #
  # def income_without_flows_value
  #   value_of( primary_txns.usable.select(&:income?) ) -
  #   value_of( secondary_txns.usable.select(&:income?) )
  # end
  #
  # def purchases_without_flows
  #   purchases_txns.reject(&:flow?)
  # end
  #
  # def sales_without_flows
  #   sales_txns.reject(&:flow?)
  # end
  #
  def income_value
    value_of( primary_txns.select(&:income?) ) - 
    value_of( secondary_txns.select(&:income?) )
  end
  
  def income_txns
    primary_txns.  select(&:income?) +
    secondary_txns.select(&:income?)
  end
  
  def sales_value
    value_of sales_txns
  end
  
  def sales_txns
    primary_txns.  select(&:decrementing?) +
    secondary_txns.select(&:accumulating?)
  end
  
  def purchases_value
    value_of purchases_txns
  end
  
  def purchases_txns
    primary_txns.  select(&:accumulating?) +
    secondary_txns.select(&:decrementing?)
  end
  
  def primary_txns
    # transactions
    transactions.where( date: day.date )
  end
  
  def secondary_txns
    # day.transactions.where( "UPPER(sd_symbol)=?", company.tag )
    day.transactions.where( date: day.date ).where( "UPPER(sd_symbol)=?", company.tag )
  end
  
  def primary_txns_value
    value_of primary_txns
  end
  
  def secondary_txns_value
    credits = secondary_txns.select(&:credit?)
    debits = secondary_txns.select(&:debit?)
    value_of( credits ) - value_of( debits )
  end
  
  def primary_prior_fund_flows_value
    lis = prior_fund_flows.select { |txn| txn.code =~ /li/i }
    los = prior_fund_flows.select { |txn| txn.code =~ /lo/i }
    wds = prior_fund_flows.select { |txn| txn.code =~ /wd/i }
    value_of( lis ) - value_of( los ) - value_of( wds )    
  end
  
  def secondary_prior_fund_flows_value
    value_of prior_secondary_transactions
  end
  
  def prior_secondary_transactions
    return [] if prior_transactions.empty?
    
    if tag =~ /legalfeepay/i
      prior_transactions.where( sd_symbol: "legalfeepay" )
    else
      []
    end
  end
  
  def tertiary_prior_fund_flows
    return [] if prior_transactions.empty?
    
    if tag =~ /cash/i
      prior_transactions.where( sd_symbol: "cash", code: "wd" )
    else
      []
    end    
  end
  
  def tertiary_prior_fund_flows_value
    value_of tertiary_prior_fund_flows
  end
  
  def prior_fund_flows_value
    primary_prior_fund_flows_value - secondary_prior_fund_flows_value + tertiary_prior_fund_flows_value
  end
  
  def prior_fund_flows
    p_txns = prior_transactions
    return [] if p_txns.empty?
    p_txns.for_holding( self ).fund_flow
  end
  
  def prior_transactions
    return [] if day.date.prev_trading_day+1 >= day.date
    range = (day.date.prev_trading_day+1..day.date-1)
    axys_portfolio.transactions.on( range )
  end
  
  def value_of( txns )
    txns.inject( BigDecimal("0.0") ) { |s, txn| s += txn.trade_amount }
  end
  
  def performance_value
    # ::Attribution::PerformanceCalculator.calc :bmv_value => bmv_value,
    ::Attribution::PerformanceCalculator.calc :bmv_value => (bmv_value + prior_fund_flows_value),
                               :emv_value => emv_value,
                               :txns_value => txns_value
  end
  
  def contribution_value
    pct_weight * (performance_value-1)
  end
  
  def pct_weight
    val_for_weight = bmv_value.zero? ? txns_value : bmv_with_prior_flows_value
    # val_for_weight = bmv_value + txns_value

    # val_for_weight / (day.bmv_value + day.txns_value)
    # val_for_weight / (day.bmv_with_flows_value)
    val_for_weight / day.bmv_with_prior_flows_value
  end
  
  def bmv_with_prior_flows_value
    bmv_value + prior_fund_flows_value
  end
  
  def inspect
    fmt = "%m/%d/%y %H:%M:%S%p"
    msg = []
    msg << "#<Attribution::Holding"
    msg << "##{id}".ljust( 5 )
    msg << "[#{company.tag}]".ljust( 10 )
    msg << "#{day.date}"
    msg << "perf: #{'% 4.5f %' % ((performance-1)*100)}".ljust( 12 )
    msg << "contrib: #{contribution ? ('% 4.5f %' % (contribution*100)) : 'NIL'}".ljust( 12 )
    msg << "#{created_at.strftime(fmt)}|#{updated_at.strftime(fmt)}"
    msg.join(' ')
  end
  
  def audit
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    
    tag = company.ticker || company.code || company.symbol
    puts "===================================================================="
    puts "| Audit for Holding ##{id} [#{tag}] #{day.date}"
    puts "--------------------------------------------------------------------"
    puts "| BMV Holding: #{bmv_axys_holding.inspect}"
    puts "| EMV Holding: #{emv_axys_holding.inspect}"
    puts "| Primary Transactions - #{primary_txns.size} total: "
    primary_txns.each do |txn|
      puts "| #{txn.inspect}"
    end
    puts "| Secondary Transactions - #{secondary_txns.size} total: "
    secondary_txns.each do |txn|
      puts "| #{txn.inspect}"
    end
    puts "| Purchases Transactions - #{purchases_txns.size} total: "
    purchases_txns.each do |txn|
      puts "| #{txn.inspect}"
    end
    puts "| Sales Transactions - #{sales_txns.size} total: "
    sales_txns.each do |txn|
      puts "| #{txn.inspect}"
    end
    puts "| Income Transactions - #{income_txns.size} total: "
    income_txns.each do |txn|
      puts "| #{txn.inspect}"
    end
    puts "|"
    puts "| IF   BMV == 0,  EMV / TXNS"
    puts "| ELSE           (EMV - TXNS) / BMV"
    puts "|"
    puts "| (where TXNS = P - I - S)"
    puts "|"
    puts "| EMV: #{emv_value}"
    puts "| BMV: #{bmv_value}"
    puts "| TXNS: #{txns_value}"
    puts "| P:   #{purchases_value}"
    puts "| S:   #{sales_value}"
    puts "| I:   #{income_value}"
    puts "| PFFV:   #{prior_fund_flows_value} (#{prior_fund_flows.size} transactions)"
    puts "| Perf:    #{(performance_value-1)*100} %"
    puts "| Contrib: #{contribution_value*100} %"
    puts "====================================================================\n"

    ActiveRecord::Base.logger = old_logger
    self
  end
  
  def recalc!
    update_attribute :performance, performance_value
    update_attribute :contribution, contribution_value
    self
  end
  
  def tag
    company.tag
  end
  
  def date
    day.date
  end
  
  def pwa
    without_logging do
      fmt = ".4f"
      puts "====================="
      puts "percent weight: #{fmt % pct_weight}"
      puts "BMV: #{fmt % bmv_value}"
      puts "TXNS: #{fmt % txns_value}"
      puts "EMV: #{fmt % emv_value}"
      puts "day bmv: #{fmt % day.bmv_value}"
      puts "====================="      
    end
  end
  
  def permitted?
    company and !company.excluded?
  end
  
end