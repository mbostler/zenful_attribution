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

require 'rails_helper'

RSpec.describe AxysSystem::Holding, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
