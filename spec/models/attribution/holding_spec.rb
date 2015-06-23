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

require 'rails_helper'

RSpec.describe Attribution::Holding, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
