require 'rails_helper'

PRECISION = 5

TICKER_OVERRIDES = {
  "DIVA_USD" => "DIVACC",
  "CASH_USD" => "CASH",
}

Holiday.seed

def get_files
  dir = File.join Rails.root, "spec/assets/attribution_reports/focus"
  files = Dir[File.join(dir, "*")]
end

def rep_results_for_ticker( rep, ticker )
  lookup_ticker = TICKER_OVERRIDES[ticker.upcase] || ticker.upcase
  rep.results[lookup_ticker]
end

def spec_file( file )
  spec_rep = AttributionSpecReport.new file
  rep = Report.new spec_rep.portfolio_name, spec_rep.start_date, spec_rep.end_date
  rep.calculate!
  
  spec_rep.holdings.each do |h|
    puts "h is : " + h.inspect
    it "should compute #{spec_rep.portfolio_name} return on #{spec_rep.start_date}-#{spec_rep.end_date} for #{h[:ticker]} is #{h[:return]}" do
      results_for_ticker = rep_results_for_ticker rep, h[:ticker]
      expect( results_for_ticker ).to_not be_blank
      normalized_report_perf = ((results_for_ticker[:performance]-1)*100).round( PRECISION ).to_s
      normalized_spec_report_perf = h[:return].to_f.round( PRECISION ).to_s
      expect( normalized_report_perf ).to eq( normalized_spec_report_perf )
    end
  end

  spec_rep.holdings.each do |h|
    it "should compute #{spec_rep.portfolio_name} contribution on #{spec_rep.start_date}-#{spec_rep.end_date} for #{h[:ticker]} is #{h[:contribution]}" do
      results_for_ticker = rep_results_for_ticker rep, h[:ticker]
      expect( results_for_ticker ).to_not be_blank
      expect( (results_for_ticker[:contribution]*100).to_f.round( PRECISION ) ).to eq( h[:contribution].to_f.round( PRECISION ) )
    end
  end
  
  it "should have total_return equal report total_return" do
    normalized_total_performance = ((rep.total_results[:performance]-1)*100).round( PRECISION )
    normalized_spec_total_performance = spec_rep.total_return.round( PRECISION )
    expect( normalized_total_performance ).to eq( normalized_spec_total_performance )
  end
  
  it "should have total_return equal sum of individual contributions" do
    summed = rep.results.inject( 0.0 ) { |s, ticker_and_results| s += ticker_and_results.last[:contribution] }
    
    normalized_summed = (100*summed).round( PRECISION )
    normalized_spec_rep_return = spec_rep.total_return.round( PRECISION )
    
    expect( normalized_summed ).to eq( normalized_spec_rep_return )
  end
end

RSpec.describe Report, type: :model do
  files = get_files
  files.each do |file|
    spec_file( file )
  end  
end

