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

class Attribution::Day < ActiveRecord::Base
  belongs_to :portfolio, class_name: "Attribution::Portfolio"
  has_many :holdings, class_name: "Attribution::Holding"
  
  validates :date, presence: true, uniqueness: { scope: :portfolio_id }
  
  before_create :ensure_daily_returns_are_calculated
  
  def ensure_daily_returns_are_calculated
    ensure_axys_data_is_created
    calculate_daily_returns
  end
  
  def calculate_daily_returns
    
  end
  
  def ensure_axys_data_is_created
    [date, prior_date].each { |d| ensure_axys_holdings_report_on( d ) }
    (prior_date+1..date).each { |d| ensure_axys_transactions_report_on( d ) }
  end
  
  def ensure_axys_holdings_report_on( date )
    holdings_report = axys_portfolio.holdings_reports.where( date: date )
    holdings_report.create! unless holdings_report.exists?
  end
  
  def ensure_axys_transactions_report_on( date )
    transactions_report = axys_portfolio.transactions_reports.where( date: date )
    transactions_report.create! unless transactions_report.exists?
  end
  
  def prior_date
    date.prev_trading_day
  end
  
  def axys_portfolio
    @axys_portfolio ||= portfolio.axys_portfolio
  end
end
