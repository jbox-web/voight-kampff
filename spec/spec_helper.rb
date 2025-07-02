# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

# Start Simplecov
SimpleCov.start do
  formatter SimpleCov::Formatter::JSONFormatter
  add_filter 'spec/'
end

require 'combustion'
require 'voight_kampff/rails'

Combustion.path = 'spec/dummy'
Combustion.initialize! :action_controller

require 'rspec/rails'

# Configure RSpec
RSpec.configure do |config|
  config.color = true
  config.fail_fast = false

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!

  config.raise_errors_for_deprecations!

  config.infer_spec_type_from_file_location!
end

# Load test helpers
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
