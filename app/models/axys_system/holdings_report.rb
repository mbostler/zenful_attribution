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

class AxysSystem::HoldingsReport < ActiveRecord::Base
  AXYS_CLASS = Axys::AppraisalWithDecimalsReport
  belongs_to :portfolio, class_name: "AxysSystem::Portfolio"
  
  validates :date, presence: true, uniqueness: { scope: :portfolio_id }
  
  before_create :ensure_holdings_report_is_downloaded
  
  def ensure_holdings_report_is_downloaded
    rep = AXYS_CLASS.new portfolio_name: portfolio.name, start: date
    rep.run! :remote => true
    
    other_attribs = { date: date, portfolio_id: portfolio.id }
    
    ActiveRecord::Base.transaction do
      
      rep[:holdings].each do |holding_attribs|
        portfolio.holdings.create! holding_attribs.merge( other_attribs )
      end
      
      rep[:cash_items].values.each do |cash_item_attribs|
        portfolio.holdings.create! cash_item_attribs.merge( other_attribs )
      end
      
    end
  end
end
