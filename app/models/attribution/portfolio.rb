# == Schema Information
#
# Table name: attribution_portfolios
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Attribution::Portfolio < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :days, class_name: "Attribution::Day", dependent: :destroy
  
  def axys_portfolio
    @axys_portfolio ||= AxysSystem::Portfolio.where( name: name ).first_or_create
  end

end
