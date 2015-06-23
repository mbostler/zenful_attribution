# == Schema Information
#
# Table name: axys_system_portfolios
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AxysSystem::Portfolio < ActiveRecord::Base
  has_many :companies, class_name: "AxysSystem::Company"
  has_many :holdings, class_name: "AxysSystem::Holding", dependent: :destroy
  has_many :transactions, class_name: "AxysSystem::Transaction", dependent: :destroy
  has_many :holdings_reports, class_name: "AxysSystem::HoldingsReport", dependent: :destroy
  has_many :transactions_reports, class_name: "AxysSystem::TransactionsReport", dependent: :destroy
  
  validates :name, uniqueness: true
end
