class DailyContribution::Writer

  def initialize( opts={} )
    @portfolio = opts[:portfolio]
    @start_date = opts[:start_date]
    @end_date = opts[:end_date]
  end
  

  def write
    data = DailyContribution::Data.new portfolio:  @portfolio, 
                                       start_date: @start_date,
                                       end_date:   @end_date
    
    data.compile                                   
    company_days = data.company_days
    days = data.days
    
    
    wb = Spreadsheet::Workbook.new
    write_daily_contribution_sheet_on_workbook wb, company_days, days
    write_cumulative_contribution_sheet_on_workbook wb, company_days, days
    
    wb.write filepath
    puts "Worksheet written to: #{filepath}"
  end
  
  def write_daily_contribution_sheet_on_workbook( wb, company_days, days )
    ws = wb.create_worksheet :name => "Daily Contribution"

    rows = []
    header_row = ["", days.map(&:date)].flatten
    rows << header_row
    
    company_days.each do |company, company_data|
      row = [company.tag]
      days.each do |day|
        date = day.date
        value = if company_data[date]
          company_data[date][:scaled_contribution]
        else
          0
        end
        row << value
      end
      
      rows << row
    end    
    
    rows.each do |row|
      ws << row
    end    
  end
  
  def write_cumulative_contribution_sheet_on_workbook( wb, company_days, days )
    # ws = wb.create_worksheet :name => "Cumulative Contribution"

    rows = []
    header_row = ["", days.map(&:date)].flatten
    rows << header_row
    
    dates = days.map(&:date)
    
    
    
    company_days.each do |company, company_data|
      row = [company.tag]
      prior_value = 0
      days.each do |day|
        date = day.date
        value = if company_data[date]
          company_data[date][:cumulative_contribution]
        else
          prior_value
        end
        row << value
        prior_value = value
      end
      
      rows << row
    end    
    
    csv_str = CSV.generate do |csv|
      rows.each do |row|
        csv << row
      end        
    end
    
    File.write( filepath("csv"), csv_str )
    # rows.each do |row|
    #   ws << row
    # end
  end
  
  def filepath( ext="xls" )
    name = @portfolio.name
    d0 = @start_date.strftime( "%-m-%-d-%Y")
    d1 = @end_date.  strftime( "%-m-%-d-%Y")
    
    filename = File.join Rails.root, "tmp", "Daily Contribution Report - #{name} - #{d0}-#{d1}.#{ext}"
  end
end
