class Report
  attr_accessor :portfolio_name, :start_date, :end_date, :results, :total_results
  
  def initialize( portfolio_name, start_date, end_date )
    @portfolio_name = portfolio_name
    @start_date = start_date.to_date
    @end_date = end_date.to_date
    validate_params
  end
  
  def validate_params
    raise "start_date must be a date" unless @start_date.is_a?( Date )
    raise "end_date must be a date" unless @end_date.is_a?( Date )
    raise "start_date cannot occur after end_date" if @start_date > @end_date
  end
  
  def calculate!
    @portfolio = Attribution::Portfolio.where( name: @portfolio_name ).first_or_create
    
    ensure_portfolio_days_are_present @portfolio, @start_date, @end_date
    
    @results = {}
    @total_results = {}
  end
  alias_method :calc, :calculate!
  
  def ensure_portfolio_days_are_present( portfolio, start_date, end_date )
    trading_days = (start_date+1..end_date).select(&:trading_day?)
    trading_days.each do |date|
      portfolio_day = @portfolio.days.where( date: date )
      portfolio_day.create! unless portfolio_day.exists?
    end    
  end
end
