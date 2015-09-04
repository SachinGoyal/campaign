json.array!(@templates) do |template|
  json.extract! template, :id, :user_id, :name, :content, :status, :created_by, :updated_by
  json.url template_url(template, format: :json)
end
