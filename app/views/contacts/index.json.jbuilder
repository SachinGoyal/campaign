json.array!(@contacts) do |contact|
  json.extract! contact, :id, :first_name, :last_name, :email, :status, :created_by, :updated_by
  json.url contact_url(contact, format: :json)
end
