# frozen_string_literal: true

require 'simplecov'

# Start Simplecov
SimpleCov.start do
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

  config.infer_spec_type_from_file_location!

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!
end

# Load test helpers
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
