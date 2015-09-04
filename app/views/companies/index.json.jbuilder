json.array!(@companies) do |company|
  json.extract! company, :id, :name, :free_emails, :status, :created_by, :updated_by
  json.url company_url(company, format: :json)
end
