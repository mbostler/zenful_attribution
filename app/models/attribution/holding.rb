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

class Attribution::Holding < ActiveRecord::Base
  belongs_to :company, class_name: "AxysSystem::Company"
  belongs_to :day, class_name: "Attribution::Day"
end
