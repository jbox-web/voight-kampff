# frozen_string_literal: true

module VoightKampff
  class Test
    CRAWLERS_FILENAME = 'crawler-user-agents.json'

    # Guards the one-time lazy initialization of the shared class-level caches so
    # concurrent first requests don't each parse the list / recompile the regexp.
    LOAD_MUTEX = Mutex.new

    # Reading an unset class variable raises NameError (unlike instance variables),
    # so the shared caches must be declared before the double-checked reads below.
    @@crawlers = nil        # rubocop:disable Style/ClassVars
    @@crawler_regexp = nil  # rubocop:disable Style/ClassVars

    attr_accessor :user_agent_string

    def initialize(user_agent_string)
      @user_agent_string = user_agent_string
    end

    def agent
      @agent ||= matching_crawler || {}
    end

    def human?
      agent.empty?
    end

    def bot?
      !human?
    end
    alias replicant? bot?

    private

    def lookup_paths
      # These paths should be orderd by priority
      base_paths = []
      base_paths << Rails.root if rails_defined?
      base_paths << VoightKampff.root

      base_paths.map { |p| p.join('config', CRAWLERS_FILENAME) }
    end

    # Extracted so the Rails-absent branch (Rack-only usage) is reachable in
    # tests: the `defined?` keyword can't be stubbed, but this method can.
    def rails_defined?
      !defined?(Rails).nil?
    end

    def preferred_path
      lookup_paths.find { |path| File.exist? path }
    end

    def matching_crawler
      return unless (match = crawler_regexp.match(@user_agent_string))

      # NOTE: MatchData#names lists ALL named groups in the pattern, not only the
      # ones that participated in the match, so we must find the group that
      # actually captured to recover the right crawler index.
      name = match.names.find { |n| match[n] }
      index = name.sub('match', '').to_i
      crawlers[index]
    end

    def crawler_regexp
      # Force-load the list outside the regexp lock so build_crawler_regexp can
      # call #crawlers without re-entering LOAD_MUTEX (Ruby mutexes aren't reentrant).
      list = crawlers
      @@crawler_regexp || LOAD_MUTEX.synchronize { @@crawler_regexp ||= build_crawler_regexp(list) } # rubocop:disable Style/ClassVars
    end

    def build_crawler_regexp(list)
      # NOTE: This is admittedly a bit convoluted but the performance gains make it worthwhile
      index = -1
      crawler_patterns = list.map do |c|
        index += 1
        "(?<match#{index}>#{c['pattern']})"
      end.join('|')
      crawler_patterns = "(#{crawler_patterns})"
      Regexp.new(crawler_patterns, Regexp::IGNORECASE)
    rescue RegexpError => e
      raise VoightKampff::Error, "crawler list contains an invalid regexp pattern: #{e.message}"
    end

    def crawlers
      @@crawlers || LOAD_MUTEX.synchronize { @@crawlers ||= load_crawlers } # rubocop:disable Style/ClassVars
    end

    def load_crawlers
      path = preferred_path
      if path.nil?
        raise VoightKampff::Error, "crawler list #{CRAWLERS_FILENAME} not found in: #{lookup_paths.join(', ')}"
      end

      JSON.parse(File.read(path))
    rescue JSON::ParserError => e
      raise VoightKampff::Error, "crawler list at #{path} is not valid JSON: #{e.message}"
    end
  end
end
