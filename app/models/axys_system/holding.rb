# == Schema Information
#
# Table name: axys_system_holdings
#
#  id             :integer          not null, primary key
#  portfolio_id   :integer
#  company_id     :integer
#  bmv_holding_id :integer
#  emv_holding_id :integer
#  date           :date
#  quantity       :float
#  unit_cost      :float
#  total_cost     :float
#  price          :float
#  market_value   :float
#  pct_assets     :float
#  yield          :float
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class AxysSystem::Holding < ActiveRecord::Base
  belongs_to :portfolio, class_name: "AxysSystem::Portfolio"
  belongs_to :company, class_name: "AxysSystem::Company"

  attr_accessor :company_attribs
  
  [:cusip, :ticker, :code, :name, :security].each do |sym|
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
