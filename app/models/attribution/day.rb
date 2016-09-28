# == Schema Information
#
# Table name: attribution_days
#
#  id           :integer          not null, primary key
#  portfolio_id :integer
#  date         :date
#  performance  :float
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Attribution::Day < ActiveRecord::Base
  belongs_to :portfolio, class_name: "Attribution::Portfolio"
  has_many :holdings, class_name: "Attribution::Holding", dependent: :destroy
  
  validates :date, presence: true, uniqueness: { scope: :portfolio_id }
  
  scope :ordered, -> { order(:date) }
  
  before_create :ensure_axys_data_is_created
  after_create :calculate_daily_returns
  
  # def ensure_daily_returns_are_calculated
  #   ensure_axys_data_is_created
  # end
  #
  def calculate_daily_returns
    puts "permitted_axys_holdings is : " + permitted_axys_holdings.inspect
    permitted_axys_holdings.each do |axys_holding|
      unless holdings.exists? company_id: axys_holding.company_id
        h = holdings.create! :axys_holding => axys_holding
        puts "\t just created #{h}"
      end
    end
    
    permitted_company_ids = permitted_axys_holdings.map(&:company_id)
    permitted_axys_transactions.each do |txn|
      next if permitted_company_ids.include?( txn.company_id )
      unless holdings.exists?( company_id: txn.company_id )
        h = holdings.create! :company_id => txn.company_id
        puts "\t *** just created holding FROM TRANSACTION #{txn.inspect}"
      end
    end
    
    holdings.each(&:update_calcs)
    
    update_performance
  end
  
  def recalc!
    holdings.destroy_all
    calculate_daily_returns
  end
  
  def update_performance
    bmv_with_prior_flows_value =  summed_holdings :bmv_with_prior_flows_value
    # bmv_value =  bmv_with_flows_value
    emv_value =  summed_holdings :emv_value
    txns_value = summed_holdings :txns_value
    # txns_value = transactions.inject( BigDecimal( "0.0" ) ) { |s, t| s += t.trade_amount }
    perf = Attribution::PerformanceCalculator.calc :bmv_value => bmv_with_prior_flows_value,
                                      :emv_value => emv_value,
                                      :txns_value => txns_value
    update_attribute :performance, perf
  end
  
  def summed_holdings( sym )
    holdings.inject( BigDecimal("0.0") ) { |s, h| s += h.send( sym ) }
  end
  
  def audit
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    
    puts "BMV:  #{summed_holdings(:bmv_value)}"
    puts "PFF:  #{summed_holdings(:prior_fund_flows_value)}"
    puts "EMV:  #{summed_holdings(:emv_value)}"
    puts "TXNS: #{summed_holdings(:txns_value)}"
    puts "P:    #{summed_holdings(:purchases_value)}"
    puts "S:    #{summed_holdings(:sales_value)}"
    puts "I:    #{summed_holdings(:income_value)}"
    puts "--------------------------"
    puts "BMV used for calculating pct weight: BMV + PFF = #{summed_holdings(:bmv_with_prior_flows_value)}"
    # puts "Prior FF: #{summed_holdings(:prior_fund_flows_value)}"
    # puts "BMV_FF value: #{summed_holdings(:bmv_value) + summed_holdings(:prior_fund_flows_value)}"

    ActiveRecord::Base.logger = old_logger
    self
  end
  
  def ensure_axys_data_is_created
    [date, prior_date].each { |d| ensure_axys_holdings_report_on( d ) }
    (prior_date+1..date).each { |d| ensure_axys_transactions_report_on( d ) }
  end
  
  def ensure_axys_holdings_report_on( date )
    holdings_report = axys_portfolio.holdings_reports.where( date: date )
    holdings_report.create! unless holdings_report.exists?
  end
  
  def ensure_axys_transactions_report_on( date )
    transactions_report = axys_portfolio.transactions_reports.where( date: date )
    transactions_report.create! unless transactions_report.exists?
  end
  
  def prior_date
    date.prev_reportable_day
  end
  
  def axys_portfolio
    @axys_portfolio ||= portfolio.axys_portfolio
  end
  
  def permitted_axys_holdings
    axys_holdings.select(&:permitted?)
  end
  
  def permitted_axys_transactions
    transactions.select(&:permitted?)
  end
  
  # TODO: FINISH!
  def axys_holdings
    emv_holdings = axys_portfolio.holdings.where( date: date ).includes( :company )
    bmv_holdings = axys_portfolio.holdings.where( date: date.prev_reportable_day ).includes( :company )
    
    emv_company_tags = emv_holdings.map { |h| h.company and h.company.tag }
    bmv_allowable_holdings = bmv_holdings.reject do |h|
      h.company.nil? || emv_company_tags.include?( h.company.tag )
    end
    
    emv_holdings + bmv_allowable_holdings
  end
  
  # def prior_fund_flows_value
  #   summed_holdings :prior_fund_flows_value
  # end
  #
  #
  # def bmv_with_flows_value
  #   bmv_value + fund_flows_value
  # end
  #
  # def fund_flows
  #   date_range = (date.prev_trading_day+1..date)
  #   flows = axys_portfolio.transactions.where( date: date_range ).fund_flow
  #   flows
  # end
  #
  # def fund_flows_value
  #   fund_flows.inject( BigDecimal( "0.0" ) ) do |s, x|
  #     case x.code.upcase
  #     when /li/i
  #       s += x.trade_amount
  #     when /lo/i
  #       s -= x.trade_amount
  #     else raise "not sure how to interpret code #{x.code} for #{x.inspect}"
  #     end
  #     s
  #   end
  # end
  #
  def bmv_value
    holdings.inject( BigDecimal( "0.0" ) ) { |s, hld| s += hld.bmv_value }
  end
  
  def bmv_with_prior_flows_value
    holdings.inject( BigDecimal( "0.0" ) ) { |s, hld| s += hld.bmv_with_prior_flows_value }
  end
  
  def txns_value
    holdings.inject( BigDecimal( "0.0" ) ) { |s, hld| s += hld.txns_value }
  end
  
  def transactions
    # axys_portfolio.transactions.on( date )
    @transactions ||= axys_portfolio.transactions.on( date ).usable
  end

  def audit_transactions
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    txns = transactions.sort_by { |txn| txn.company.tag }
    
    puts "===================================================================="
    puts "| #{txns.size} Transactions for #{portfolio.name} on #{date.strftime('%m/%d/%Y')}"
    puts "--------------------------------------------------------------------"
    txns.each do |txn|
      puts "| #{txn.inspect}"
    end
    puts "====================================================================\n"
    
    ActiveRecord::Base.logger = old_logger
    self
  end
  alias_method :adt, :audit_transactions
  
  def audit_holdings
    holdings.sort_by { |h| h.company.tag }.each do |h|
      puts h.inspect
    end

    audit_totals
  end
  alias_method :adh, :audit_holdings
  
  def audit_totals
    puts "DAILY PERFORMANCE FOR #{axys_portfolio.name} on #{date}: #{performance}, ie: #{pretty_performance}"
    
    summed_perf = (holdings.inject(BigDecimal("0.0") ) { |s, h| s += h.contribution } * 100).round(6)
    adj_calcd_perf = ((performance-1)*100).round(6)
    if summed_perf == adj_calcd_perf
      puts "CHECK: OK! Perf is #{adj_calcd_perf}%"
    else
      puts "CHECK: BAD : calc'd perf is #{adj_calcd_perf}, summed perf is #{summed_perf}"
    end    
  end
  
  def pretty_performance
    '%.5f %' % ((performance-1)*100)
  end
  
  def pperf
    if self.performance
      ((self.performance - 1)*100).to_f.round(5).to_s + " %"
    else
      puts "performance hasn't been calc'd yet! #{self.inspect}"
    end
  end
  
  def inspect
    fmt = "%m/%d/%y %H:%M:%S%p"
    "#<Attribution::Day ##{id} #{portfolio.name}|##{portfolio_id} on #{date} : #{pperf} | #{created_at.strftime(fmt)}|#{updated_at.strftime(fmt)}"
  end
  
  def self.ensure_portfolio_days_are_present( portfolio, dates )
    sorted_dates = dates.sort
    sorted_dates.each do |date|
      portfolio_day = portfolio.days.where( date: date )
      unless portfolio_day.exists?
        puts "*** downloading info for #{portfolio} on #{date}"
        (d = portfolio_day.create!)
        puts "*** successfully downloaded info for #{portfolio} on #{date}! ***"
      end
    end
    puts "Portfolio days ensured for #{portfolio.name} on #{sorted_dates.first} - #{sorted_dates.last}"
  end
  
  def self.date_range(d0, d1)
    (d0+1..d1).select(&:reportable_day?)
  end
  
  
end
