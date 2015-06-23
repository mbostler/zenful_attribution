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

require 'rails_helper'

RSpec.describe Attribution::Day, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
