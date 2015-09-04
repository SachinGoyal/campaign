json.array!(@settings) do |setting|
  json.extract! setting, :id, :user_id, :site_title, :admin_email, :admin_footer_content
  json.url setting_url(setting, format: :json)
end
