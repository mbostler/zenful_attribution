class AttributionSpecReport
  attr_accessor :portfolio_name, :start_date, :end_date, :total_return, :total_contribution, :holdings
  
  PORTFOLIO_NAMES = {
    "Daruma Ginkgo Fund, LP - Transactions" => "ginkgo"
  }
  
  
  def initialize( filepath )
    xlsx = Roo::Excelx.new filepath
    data = xlsx.to_a
    validate_data( data )
    # @i = 0
    # data.each do |r|
    #   puts "#{@i}: #{r.inspect}"
    #   @i += 1
    # end
  end
  
  def validate_data( rows )
    unless rows[0][1].strip == "Attribution Report" 
      raise "Not a FactSet Attribution Report! Make sure you run the default AttributionScratch Report"
    end
    
    name_token = rows[1][1].strip
    @portfolio_name = PORTFOLIO_NAMES[name_token]
    raise "couldn't ID a portfolio from token #{name_token.inspect}" unless @portfolio_name
    
    date_fmt = "%m/%d/%Y"
    date_tokens = rows[3][1].strip.split(" to ")
    @start_date = Date.strptime date_tokens.first, date_fmt
    @end_date = Date.strptime date_tokens.last, date_fmt
    
    raise "couldn't parse start_date from #{date_tokens.first}" unless @start_date.is_a?( Date )
    raise "couldn't parse end_date from #{date_tokens.last}" unless @end_date.is_a?( Date )
    
    idx = 9
    @total_return = BigDecimal rows[idx][5].to_s
    @total_contribution = BigDecimal rows[idx][6].to_s
    
    raise "couldn't find total return (looking at row #{idx}: #{rows[idx].inspect})" unless @total_return
    raise "couldn't find total contribution (looking at row #{idx}: #{rows[idx].inspect})" unless @total_contribution
    
    eligible_rows = rows[10..-1].select { |r| !!r.first }
    @holdings = eligible_rows.map { |r| row_to_holding( r ) }
    puts "@holdings is : " + @holdings.inspect
    raise "holdings are empty! something seems off" if @holdings.empty?
  end
  
  def row_to_holding( row )
    {
      :ticker => row[0],
      :return => BigDecimal( row[5].to_s ),
      :contribution => BigDecimal( row[6].to_s )
    }
  end
  
end