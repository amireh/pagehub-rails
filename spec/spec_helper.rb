ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'rack/test'
require 'rack/utils'
require 'paperclip/matchers'

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Paperclip::Shoulda::Matchers

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
  config.mock_with :rspec

  def app
    PageHub::Application
  end

  if ENV['VERBOSE']
    Rails.logger = Logger.new(STDOUT)
  end
end

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

at_exit do
  FileUtils.rm_rf(Rails.root.join('tmp', 'test').to_s)
end
