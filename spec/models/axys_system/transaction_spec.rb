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

require 'rails_helper'

RSpec.describe AxysSystem::Transaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
