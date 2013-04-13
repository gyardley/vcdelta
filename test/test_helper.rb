ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'json_test_helper.rb'

require 'webmock/test_unit'
WebMock.allow_net_connect!

server = JsonServer.boot
JsonServer.base = "http://"+[server.host, server.port].join(':')

Capybara.default_driver = :webkit
DatabaseCleaner.strategy = :truncation

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Sorcery::TestHelpers::Rails

  self.use_transactional_fixtures = false

  teardown do
    DatabaseCleaner.clean
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end