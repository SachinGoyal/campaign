json.array!(@campaigns) do |campaign|
  json.extract! campaign, :id, :user_id, :name, :description, :status, :created_by, :updated_by
  json.url campaign_url(campaign, format: :json)
end
