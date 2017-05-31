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

class AxysSystem::Holding < ApplicationRecord
  belongs_to :portfolio, class_name: "AxysSystem::Portfolio"
  belongs_to :company, class_name: "AxysSystem::Company", optional: true
  belongs_to :bmv_holding, class_name: "Attribution::Holding", foreign_key: :bmv_holding_id, optional: true
  belongs_to :emv_holding, class_name: "Attribution::Holding", foreign_key: :emv_holding_id, optional: true

  attr_accessor :company_attribs
  
  [:cusip, :ticker, :code, :name, :security].each do |sym|
    attr_accessor sym
    define_method sym.to_s + "=" do |arg|
      @company_attribs ||= {}
      @company_attribs[sym] = arg
    end
  end
  
  before_save :associate_company, prepend: true
    
  def permitted?
    return false if company and company.excluded?
    true
  end

private
  def associate_company
    unless @company_attribs.nil? || @company_attribs.empty?
      co = AxysSystem::Company.find_or_create_from_attribs!( @company_attribs )
      self.company_id = co.id
    end
  end
  
end
