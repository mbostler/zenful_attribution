json.array!(@reports_daily_contributions) do |reports_daily_contribution|
  json.extract! reports_daily_contribution, :id
  json.url reports_daily_contribution_url(reports_daily_contribution, format: :json)
end
