# frozen_string_literal: true

require 'spec_helper'
require 'net/http'

RSpec.describe VoightKampff do
  subject { described_class }

  describe '.import_crawler_list' do
    def response_double(klass, code, message, body)
      response = klass.new('1.1', code, message)
      allow(response).to receive(:body).and_return(body)
      response
    end

    it 'returns the body when the server responds with valid JSON' do
      response = response_double(Net::HTTPOK, '200', 'OK', '[{"pattern":"Bot"}]')
      allow(Net::HTTP).to receive(:get_response).and_return(response)
      expect(subject.import_crawler_list('http://example.test/list.json')).to eq('[{"pattern":"Bot"}]')
    end

    it 'raises on a non-success status instead of returning the error body' do
      response = response_double(Net::HTTPNotFound, '404', 'Not Found', '404: not found')
      allow(Net::HTTP).to receive(:get_response).and_return(response)
      expect { subject.import_crawler_list('http://example.test/list.json') }
        .to raise_error(VoightKampff::Error, /HTTP 404/)
    end

    it 'raises when a successful body is not valid JSON' do
      response = response_double(Net::HTTPOK, '200', 'OK', '<html>oops</html>')
      allow(Net::HTTP).to receive(:get_response).and_return(response)
      expect { subject.import_crawler_list('http://example.test/list.json') }
        .to raise_error(VoightKampff::Error, /not valid JSON/)
    end

    it 'follows redirects up to the limit then gives up' do
      response = response_double(Net::HTTPMovedPermanently, '301', 'Moved', '')
      response['location'] = 'http://example.test/loop'
      allow(Net::HTTP).to receive(:get_response).and_return(response)
      expect { subject.import_crawler_list('http://example.test/list.json') }
        .to raise_error(VoightKampff::Error, /redirect/)
    end
  end

  HUMANS.each_value do |ua_string|
    context "when user agent is #{ua_string}" do
      let(:user_agent_string) { ua_string }

      it 'is not a replicant' do
        expect(subject.human?(user_agent_string)).to be true
        expect(subject.bot?(user_agent_string)).to be false
      end
    end
  end

  REPLICANTS.each_value do |ua_string|
    context "when user agent is #{ua_string}" do
      let(:user_agent_string) { ua_string }

      it 'is a replicant' do
        expect(subject.bot?(user_agent_string)).to be true
        expect(subject.human?(user_agent_string)).to be false
      end
    end
  end
end
