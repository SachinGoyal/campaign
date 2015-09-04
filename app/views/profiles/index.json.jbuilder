json.array!(@profiles) do |profile|
  json.extract! profile, :id, :name, :status, :created_by, :updated_by
  json.url profile_url(profile, format: :json)
end
