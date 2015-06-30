require 'rails_helper'

def get_files
  dir = File.join Rails.root, "spec/assets/attribution_reports/focus"
  files = Dir[File.join(dir, "*")]
end

def spec_file( file )
  spec_rep = AttributionSpecReport.new file
  rep = Report.new spec_rep.portfolio_name, spec_rep.start_date, spec_rep.end_date
  rep.calculate!
  spec_rep.holdings.each do |h|
    it "should compute #{spec_rep.portfolio_name} return on #{spec_rep.start_date}-#{spec_rep.end_date} for #{h[:ticker]} is #{h[:return]}" do
      results_for_ticker = rep.results[h[:ticker]]
      expect( results_for_ticker ).to_not be_blank
      expect( h[:return].to_f ).to eq( results_for_ticker[:return].to_f )
    end
  end

  spec_rep.holdings.each do |h|
    it "should compute #{spec_rep.portfolio_name} contribution on #{spec_rep.start_date}-#{spec_rep.end_date} for #{h[:ticker]} is #{h[:contribution]}" do
      results_for_ticker = rep.results[h[:ticker]]
      expect( results_for_ticker ).to_not be_blank
      expect( h[:contribution].to_f.round(5) ).to eq( (results_for_ticker[:contribution]*100).to_f.round(5) )
    end
  end
  
  it "should have total_return equal report total_return" do
    expect( rep.total_results[:return] ).to eq( spec_rep.total_return )
  end
  
  it "should have total_return equal sum of individual contributions" do
    summed = rep.results.inject( 0.0 ) { |s, ticker_and_results| s += ticker_and_results.last[:contribution] }
    expect( summed ).to eq( spec_rep.total_return )
  end
end

RSpec.describe Report, type: :model do
  files = get_files
  files.each do |file|
    spec_file( file )
  end  
end

