# ENV["RAILS_ENV"] ||= 'test'

# require File.expand_path("../../config/environment", __FILE__)
# require 'rspec/rails'
# require 'rack/test'
# require 'rack/utils'
# require 'paperclip/matchers'

# ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # config.include Rack::Test::Methods
  # config.include Paperclip::Shoulda::Matchers

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    # For more details, see:
    #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
    expectations.syntax = :expect
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Enable only the newer, non-monkey-patching expect syntax.
    # For more details, see:
    #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
    mocks.syntax = :expect

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended.
    mocks.verify_partial_doubles = true
  end

  Kernel.srand config.seed

  # def app
  #   PageHub::Application
  # end

  # if ENV['VERBOSE']
  #   Rails.logger = Logger.new(STDOUT)
  # end
end

# require_relative "./support/factories"

# Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

