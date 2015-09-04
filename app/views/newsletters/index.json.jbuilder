json.array!(@newsletters) do |newsletter|
  json.extract! newsletter, :id, :campeign_id, :template_id, :name, :subject, :from_name, :from_address, :reply_email, :created_by, :updated_by
  json.url newsletter_url(newsletter, format: :json)
end
