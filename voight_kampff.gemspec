# frozen_string_literal: true

require_relative 'lib/voight_kampff/version'

Gem::Specification.new do |s|
  s.name        = 'voight_kampff'
  s.version     = VoightKampff::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Adam Crownoble"]
  s.email       = ["adam@codenoble.com"]
  s.homepage    = "https://github.com/biola/Voight-Kampff"
  s.summary     = "Voight-Kampff bot detection"
  s.description = 'Voight-Kampff detects bots, spiders, crawlers and replicants'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 3.0.0'

  s.files = `git ls-files`.split("\n")

  s.add_dependency 'rack', ['>= 1.4']

  s.add_development_dependency 'combustion', '~> 1.1'
  s.add_development_dependency 'rails', '>= 5.2'
  s.add_development_dependency 'rspec-rails', '~> 3.8'
end
