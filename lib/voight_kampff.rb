# frozen_string_literal: true

require 'json'

require 'voight_kampff/test'
require 'voight_kampff/methods'

module VoightKampff
  # Raised when the crawler user-agent list cannot be located, read, parsed or compiled.
  class Error < StandardError; end

  class << self
    def root
      require 'pathname'
      Pathname.new File.expand_path '..', File.dirname(__FILE__)
    end

    def human?(user_agent_string)
      test(user_agent_string).human?
    end

    def bot?(user_agent_string)
      test(user_agent_string).bot?
    end
    alias replicant? bot?

    # Fetch and validate a fresh crawler user-agent list. Follows redirects,
    # rejects non-success responses and bodies that don't parse as JSON, so a
    # moved URL or an error page can never silently overwrite the real list.
    def import_crawler_list(url, limit: 5)
      require 'net/http'
      raise VoightKampff::Error, "too many HTTP redirects while fetching #{url}" if limit.negative?

      handle_crawler_list_response(Net::HTTP.get_response(URI(url)), url, limit)
    end

    private

    def handle_crawler_list_response(response, url, limit)
      case response
      when Net::HTTPSuccess     then validate_crawler_list(response.body, url)
      when Net::HTTPRedirection then import_crawler_list(response['location'], limit: limit - 1)
      else
        raise VoightKampff::Error, "failed to fetch crawler list from #{url}: HTTP #{response.code} #{response.message}"
      end
    end

    # Ensure a successful body actually parses as JSON before it can overwrite the
    # real list; an HTML error page or truncated download is rejected here.
    def validate_crawler_list(raw, url)
      body = raw.to_s.dup.force_encoding(Encoding::UTF_8)
      JSON.parse(body)
      body
    rescue JSON::ParserError => e
      raise VoightKampff::Error, "crawler list fetched from #{url} is not valid JSON: #{e.message}"
    end

    def test(user_agent_string)
      VoightKampff::Test.new(user_agent_string)
    end
  end
end
