json.array!(@campeigns) do |campeign|
  json.extract! campeign, :id, :user_id, :name, :description, :status, :created_by, :updated_by
  json.url campeign_url(campeign, format: :json)
end
