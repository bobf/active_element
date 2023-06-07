# frozen_string_literal: true

ENV['RAILS_ENV'] = 'production'
ENV['SECRET_KEY_BASE'] = 'dummy-application-secret-key-base'
require_relative 'dummy/config/environment'

require 'active_element'

require 'devpack'
require 'rspec/rails'
require 'rspec/its'
require 'rspec/html'
require 'rspec/file_fixtures'
require 'webmock/rspec'

WebMock.disable_net_connect!

Dir[File.join(__dir__, 'support', '**', '*.rb')].sort.each { |path| require path }
Dir[File.join(__dir__, 'factories', '**', '*.rb')].sort.each { |path| require path }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.example_status_persistence_file_path = '.rspec_status'
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
  config.include ExamplesTable
  config.include UsersTable
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.around { |example| Paintbrush.with_configuration(colorize: false) { example.call } }
  config.around do |example|
    next example.run unless example.metadata[:type] == :request

    truncate_example_tables
    truncate_users_table
    create_example_tables
    create_users_table
    example.run
  end

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
