# frozen_string_literal: true

namespace :voight_kampff do
  desc 'Import a new crawler-user-agents.json file'
  task :import_user_agents, :url do |_t, args| # rubocop:disable Rails/RakeEnvironment
    require 'voight_kampff'

    args.with_defaults url: 'https://raw.githubusercontent.com/monperrus/crawler-user-agents/master/crawler-user-agents.json'

    begin
      contents = VoightKampff.import_crawler_list(args[:url])
    rescue VoightKampff::Error => e
      abort "voight_kampff:import_user_agents - #{e.message}"
    end

    File.write('./config/crawler-user-agents.json', contents)
    puts "voight_kampff:import_user_agents - imported #{contents.bytesize} bytes from #{args[:url]}"
  end
end
