# == Schema Information
#
# Table name: axys_system_holdings_reports
#
#  id           :integer          not null, primary key
#  portfolio_id :integer
#  date         :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe AxysSystem::HoldingsReport, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
