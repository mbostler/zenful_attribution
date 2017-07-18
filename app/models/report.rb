class Report
  extend ActiveModel::Naming
  def to_model
    # dummy method to appease rails
  end
  include Auditing
  attr_accessor :portfolio_name, :start_date, :end_date, :results, :total_results, :portfolio
  
  def initialize( portfolio_name, start_date, end_date )
    @portfolio_name = portfolio_name
    @portfolio = Attribution::Portfolio.where( name: @portfolio_name ).first_or_create
    
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
    Holiday.seed # ensure holidays are seeded
    
    # @portfolio.days.destroy_all # TODO: remove this after testing over!
    
    ensure_portfolio_days_are_present @portfolio, @start_date, @end_date
    
    @total_results = collect_total_results
    @results = collect_results
    audit
    self
  end
  alias_method :calc, :calculate!
  
  def collect_total_results
    total_performance = days.map(&:performance).inject( BigDecimal("1.0") ) { |s, x| s *= x }
        
    {
      performance: total_performance
    }
  end
  
  def audit
    print_results @results
    puts "total return: #{pp( @total_results[:performance]-1 )}"
    true
  end
  
  def audit_performance
    sorted_results = @results.sort_by { |r| r[1][:performance]*-1 }
    print_results sorted_results
  end
  
  def audit_contribution
    sorted_results = @results.sort_by { |r| r[1][:contribution]*-1 }
    print_results sorted_results
  end
  
  def print_results( result_data )
    result_data.each do |tag, result|
      perf = perf2string result[:performance]
      contrib = contrib2string result[:contribution]
      puts "#{tag.ljust(7)}: perf: #{perf.rjust(12)}   |   contrib: #{contrib.rjust(12)}"
    end
  end
  
  def a( t )
    without_logging do
      tag = t.upcase
      puts "auditing #{tag}"
    
      if @results[tag].nil?
        puts "could not find results for #{tag}"
        return
      end
    
      puts "#{tag} --- performance: #{pp @results[tag][:performance]-1} contribution: #{pp @results[tag][:contribution]}"
      days_by_holding[tag].reverse.each do |h|
        msg = "#<Attribution::Holding ##{h.id} "
        msg << "[#{h.tag}]".ljust( 10 )
        msg << "#{h.day.date.strftime('%a, %m/%d/%y')} "
        msg << "perf: #{pp (h.performance-1)} ".ljust( 12 )
        msg << "contrib: #{h.contribution ? ('% 4.5f %' % (h.contribution*100)) : 'NIL'} ".ljust( 12 )
        mult = cumulative_performance_multiplier( h.day.date )
        msg << "multiplier: #{mult.to_f.round( 6 )}".ljust( 12 )
        puts msg
      end
      puts "done. ###---\n"
    end
  end
  
  def collect_results
    results_by_holding = {}
    days_by_holding.each do |tag, holdings|
      results_by_holding[tag.upcase] = {
        performance: cumulative_performance( holdings ),
        contribution: cumulative_contribution( holdings )
      }
    end
    
    results_by_holding
  end
  
  def days_by_holding
    trading_days = date_range start_date, end_date
    report_days = @portfolio.days.where( date: trading_days ).includes( :holdings => :company ) 
    days_by_holding = Hash.new { |h, k| h[k] = [] }
    
    report_days.each do |day|
      day.permitted_holdings.each do |holding|
      # day.holdings.each do |holding|
        c = holding.company
        # tag = c.ticker || c.code
        days_by_holding[c.tag] << holding
      end
    end
    
    days_by_holding    
  end
  
  def cumulative_performance( holdings )
    puts "holdings is : " + holdings.inspect
    holdings.map(&:performance).inject( BigDecimal("1.0") ) { |s, x| s *= x }
  end
  
  def cumulative_contribution( holdings )
    scaled_contributions = holdings.map do |holding|
      puts "holding is: #{holding.inspect}"
      multiplier = cumulative_performance_multiplier( holding.date )
      holding.contribution * multiplier
    end
    
    scaled_contributions.inject( BigDecimal("0.0") ) { |s, x| s += x }
  end
  
  def cumulative_performance_multiplier( date )
    @cumulative_performance_multipliers ||= {}
    
    if @cumulative_performance_multipliers[date]
      return @cumulative_performance_multipliers[date]
    end
    
    days_to_scale_with = days.select { |d| d.date > date }
    multiplier = days_to_scale_with.inject( BigDecimal( "1.0" ) ) { |s, x| s *= x.performance }
    
    @cumulative_performance_multipliers[date] = multiplier
  end
  
  def ensure_portfolio_days_are_present( portfolio, start_date, end_date )
    trading_days = date_range start_date, end_date
    trading_days.each do |date|
      portfolio_day = @portfolio.days.where( date: date )
      unless portfolio_day.exists?
        puts "*** downloading info for #{portfolio} on #{date}"
        (d = portfolio_day.create!)
        puts "*** successfully downloaded info for #{portfolio} on #{date}! ***"
      end
    end    
  end
  
  def date_range(d0, d1)
    (d0+1..d1).select(&:reportable_day?)
  end
  
  def days
    @days ||= @portfolio.days.where( date: date_range( @start_date, @end_date ) ).ordered
  end
  
  def summarize
    total_perf = ((total_results[:performance].to_f - 1)*100).round(3)
    puts "total performance: #{total_perf} %"
  end
  
  def audit_total
    days.each do |day|
      puts "#{day.date} : #{pp( day.performance-1 )}"
    end
  end
  
  def recalc!
    days.each(&:recalc!)
  end
end
