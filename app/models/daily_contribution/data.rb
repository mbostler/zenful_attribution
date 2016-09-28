class DailyContribution::Data
  attr_accessor :days, :company_days
  
  def initialize( opts={} )
    @portfolio = opts[:portfolio]
    @start_date = opts[:start_date]
    @end_date = opts[:end_date]
  end
  
  def compile
    dates = reportable_dates @start_date, @end_date
    Attribution::Day.ensure_portfolio_days_are_present( @portfolio, dates )
    @days = @portfolio.days.where( date: dates ).includes( :holdings => :company )
    
    companies = uniq_companies @days
    
    @company_days = compile_company_days companies, @days    
    @company_days = add_scaled_contribution_to_company_days @company_days, @days
    @company_days = add_cumulative_contribution_to_company_days @company_days
    
    # puts "multipliers is : " + multipliers.inspect
    # puts "company_days is : " + company_days.inspect
    company_days
  end
  
  def add_scaled_contribution_to_company_days( company_days, days )
    multipliers = compile_multipliers days

    days.each.with_index do |day, i|
      day.holdings.each do |holding|
        c = holding.company
        d = day.date
        if company_days[c][d]
          multiple = multipliers[i]
          company_days[c][d][:scaled_contribution] = company_days[c][d][:contribution] * multiple
        end
      end
    end
    
    company_days
  end
  
  def add_cumulative_contribution_to_company_days( company_days )
    company_days.each do |company, days_for_company|
      cumulative = BigDecimal( "0.0" )
      days_for_company.each do |date, stats_for_date|
        stats_for_date[:cumulative_contribution] = stats_for_date[:scaled_contribution] + cumulative
        cumulative += stats_for_date[:scaled_contribution]
      end
    end
    
    company_days
  end
  
  def compile_company_days( companies, days )
    collection = companies.inject( {} ) do |hsh, c|
      hsh[c] = {}
      hsh
    end
    
    days.each do |d|
      d.holdings.each do |h|
        attribs = {
          performance: h.performance,
          contribution: h.contribution
        }
        collection[h.company][d.date] = attribs
      end
    end
    
    collection
  end
  
  def compile_multipliers( days )
    day_returns = days.map(&:performance)[1..-1]
    multipliers = []
    cumulative_mult = BigDecimal( "1.0" )
    day_returns.reverse.each do |r|
      cumulative_mult *= r
      multipliers.unshift cumulative_mult
    end
    multipliers << 1.0
    raise "multipliers size (#{multipliers.size}) != days size (#{days.size})" unless multipliers.size == days.size
    
    multipliers
  end
  
  def uniq_companies( days )
    days.map { |d| d.holdings }.flatten.map(&:company).uniq
  end
  
  def reportable_dates(d0, d1)
    (d0+1..d1).select(&:reportable_day?)
  end
end
