# == Schema Information
#
# Table name: axys_system_transactions
#
#  id           :integer          not null, primary key
#  portfolio_id :integer
#  company_id   :integer
#  holding_id   :integer
#  date         :date
#  code         :string
#  security     :string
#  close_method :string
#  lot          :string
#  trade_date   :date
#  settle_date  :date
#  sd_type      :string
#  sd_symbol    :string
#  quantity     :float
#  trade_amount :float
#  cusip        :string
#  symbol       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class AxysSystem::Transaction < ActiveRecord::Base
  belongs_to :portfolio, class_name: "AxysSystem::Portfolio"
  belongs_to :company, class_name: "AxysSystem::Company"
  belongs_to :holding, class_name: "Attribution::Holding"
  
  attr_accessor :company_attribs
  
  CREDIT_CODES = {
    by: false,
    in: false,
    dp: false,
    sl: true
  }

  [:security, :cusip, :symbol].each do |sym|
    attr_accessor sym
    define_method sym.to_s + "=" do |arg|
      @company_attribs ||= {}
      if sym == :symbol
        @company_attribs[:code] = arg
      else
        @company_attribs[sym] = arg
      end
    end
  end
  
  before_save :associate_company
    
  def associate_company
    unless @company_attribs.nil? || @company_attribs.empty?
      co = AxysSystem::Company.find_or_create_from_attribs!( @company_attribs )
      self.company_id = co.id
    end
  end
  
  def inspect
    msg = ""
    msg = "<# AxysSystem::Transaction ##{id.to_s.ljust(5)} "
    msg << "[#{company.tag}]#{cusip}|#{symbol}".ljust(25)
    msg << "#{quantity.to_i}@$#{'%.2f' % trade_amount }".ljust(23)
    msg << "Cd: #{code}".ljust(8)
    msg << "Sec: #{security}".ljust(5)
    msg << "SD-TYPE: #{sd_type}".ljust(15)
    msg << "SD-SYM: #{sd_symbol} "
  end
  
  def credit?
    res = CREDIT_CODES[code.to_sym]
    if res.nil?
      raise "not sure whether to treat this transaction as a credit or a debit! #{self.inspect}"
    end
    res
  end
  
  def debit?
    !credit?
  end

  def permitted?
    return false if company and company.excluded?
    true
  end
  
  def income?
    ["in"].include? code.downcase    
  end
  
  def accumulating?
    ["dp", "by"].include? code.downcase    
  end

  def decrementing?
    ["sl"].include? code.downcase    
  end
end
