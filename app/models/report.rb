class Report
  attr_accessor :portfolio_name, :start_date, :end_date, :results, :total_results, :portfolio
  
  def initialize( portfolio_name, start_date, end_date )
    @portfolio_name = portfolio_name
    @start_date = datify start_date
    @end_date = datify end_date
    validate_params
  end
  
  def datify( input )
    if input.is_a? String
      Date.strptime input, "%m/%d/%Y"
    else
      input.to_date
    end
  end
  
  def validate_params
    raise "start_date must be a date" unless @start_date.is_a?( Date )
    raise "end_date must be a date" unless @end_date.is_a?( Date )
    raise "start_date cannot occur after end_date" if @start_date > @end_date
  end
  
  def calculate!
    @portfolio = Attribution::Portfolio.where( name: @portfolio_name ).first_or_create
    
    @portfolio.days.destroy_all # TODO: remove this after testing over!
    
    ensure_portfolio_days_are_present @portfolio, @start_date, @end_date
    
    @total_results = {}
    puts "SET"
    @results = collect_results
    audit
    self
  end
  alias_method :calc, :calculate!
  
  def audit
    @results.each do |tag, result|
      perf = perf2string result[:performance]
      contrib = contrib2string result[:contribution]
      puts "#{tag.ljust(7)}: perf: #{perf.rjust(10)} | contrib: #{contrib.rjust(10)}"
    end
  end
  
  def perf2string( num )
    proper_num_to_pretty_num num-1
  end
  
  def contrib2string( num )
    proper_num_to_pretty_num num
  end
  
  def proper_num_to_pretty_num( x )
    '%0.4f %' % (x.to_f*100)
  end
  
  def collect_results
    trading_days = date_range start_date, end_date
    report_days = @portfolio.days.where date: trading_days
    days_by_holding = Hash.new { |h, k| h[k] = [] }
    
    report_days.each do |day|
      day.holdings.each do |holding|
        c = holding.company
        tag = c.ticker || c.code
        days_by_holding[tag] << holding
      end
    end
    
    results_by_holding = {}
    days_by_holding.each do |tag, holdings|
      results_by_holding[tag] = {
        performance: cumulative_performance( holdings ),
        contribution: cumulative_contribution( holdings )
      }
    end
    
    results_by_holding
  end
  
  def cumulative_performance( holdings )
    puts "holdings is : " + holdings.inspect
    holdings.map(&:performance).inject( BigDecimal("1.0") ) { |s, x| s *= x }
  end
  
  def cumulative_contribution( holdings )
    holdings.map(&:contribution).inject( BigDecimal("0.0") ) { |s, x| s += x }
  end
  
  def ensure_portfolio_days_are_present( portfolio, start_date, end_date )
    trading_days = date_range start_date, end_date
    trading_days.each do |date|
      portfolio_day = @portfolio.days.where( date: date )
      portfolio_day.create! unless portfolio_day.exists?
    end    
  end
  
  def date_range(d0, d1)
    (d0+1..d1).select(&:trading_day?)
  end
  
  def days
    @portfolio.days.where( date: date_range( @start_date, @end_date ) )
  end
end
