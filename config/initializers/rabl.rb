Rabl.configure do |config|
  config.escape_all_output = true
  config.json_engine = ActiveSupport::JSON
  config.view_paths << Rails.root.join('app', 'views')
end