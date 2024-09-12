# frozen_string_literal: true

module VoightKampff
  module Methods
    def human?
      VoightKampff::Test.new(user_agent).human?
    end

    def bot?
      VoightKampff::Test.new(user_agent).bot?
    end
    alias replicant? bot?
  end
end
