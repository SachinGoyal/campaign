json.array!(@functions) do |function|
  json.extract! function, :id, :controller, :action
  json.url function_url(function, format: :json)
end
