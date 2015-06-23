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
  
  attr_accessor :company_attribs

  [:security, :cusip, :symbol].each do |sym|
    attr_accessor sym
    define_method sym.to_s + "=" do |arg|
      @company_attribs ||= {}
      @company_attribs[sym] = arg
    end
  end
  
  before_save :associate_company
    
  def associate_company
    co = AxysSystem::Company.find_or_create_from_attribs!( @company_attribs )
    self.company_id = co.id
  end
end
