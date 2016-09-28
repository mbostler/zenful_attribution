json.array!(@daily_contribution_reports) do |daily_contribution_report|
  json.extract! daily_contribution_report, :id
  json.url daily_contribution_report_url(daily_contribution_report, format: :json)
end
