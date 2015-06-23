# == Schema Information
#
# Table name: axys_system_transactions_reports
#
#  id           :integer          not null, primary key
#  portfolio_id :integer
#  date         :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class AxysSystem::TransactionsReport < ActiveRecord::Base
  AXYS_CLASS = Axys::TransactionsWithSecuritiesReport

  belongs_to :portfolio, class_name: "AxysSystem::Portfolio"
  
  validates :date, presence: true, uniqueness: { scope: :portfolio_id }

  before_create :ensure_transactions_report_is_downloaded
  
  def ensure_transactions_report_is_downloaded
    rep = AXYS_CLASS.new portfolio_name: portfolio.name, start: date, end: date
    rep.run! :remote => true
    
    other_attribs = { date: date, portfolio_id: portfolio.id }
    
    ActiveRecord::Base.transaction do
      
      rep[:transactions].each do |txn_attribs|
        portfolio.transactions.create! txn_attribs.merge( other_attribs )
      end
      
    end
  end

end
