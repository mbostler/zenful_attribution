# == Schema Information
#
# Table name: axys_system_companies
#
#  id         :integer          not null, primary key
#  cusip      :string
#  ticker     :string
#  code       :string
#  name       :string
#  security   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  symbol     :string
#

require 'rails_helper'

RSpec.describe AxysSystem::Company, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
