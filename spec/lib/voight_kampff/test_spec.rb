# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VoightKampff::Test do
  subject { described_class.new(user_agent_string) }

  let(:user_agent_string) { nil }

  HUMANS.each do |name, ua_string|
    context "when user agent is #{name}" do
      let(:user_agent_string) { ua_string }

      it 'is not a replicant' do
        expect(subject.human?).to be true
        expect(subject.bot?).to be false
      end
    end
  end

  REPLICANTS.each do |name, ua_string|
    context "when user agent is #{name}" do
      let(:user_agent_string) { ua_string }

      it 'is a replicant' do
        expect(subject.bot?).to be true
        expect(subject.human?).to be false
      end
    end
  end

  describe '#agent' do
    it 'returns the crawler entry that actually matched, not always the first one' do
      test = described_class.new('Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)')
      expect(test.agent['pattern']).to match(/bingbot/i)
    end

    it 'returns an empty hash for a human user agent' do
      test = described_class.new(HUMANS['Chrome'])
      expect(test.agent).to eq({})
    end
  end

  describe 'crawler list loading' do
    it 'raises a clear error when the crawler list cannot be found' do
      test = described_class.new('x')
      allow(test).to receive(:preferred_path).and_return(nil)
      expect { test.send(:load_crawlers) }.to raise_error(VoightKampff::Error, /not found/)
    end

    it 'raises a clear error when the crawler list is not valid JSON' do
      test = described_class.new('x')
      allow(test).to receive(:preferred_path).and_return('bad.json')
      without_partial_double_verification { allow(File).to receive(:read).and_return('{ not json') }
      expect { test.send(:load_crawlers) }.to raise_error(VoightKampff::Error, /valid JSON/)
    end

    it 'raises a clear error when a crawler pattern is not a valid regexp' do
      test = described_class.new('x')
      expect { test.send(:build_crawler_regexp, [{ 'pattern' => '(' }]) }
        .to raise_error(VoightKampff::Error, /invalid regexp/)
    end
  end

  describe 'crawler list lookup paths' do
    it 'falls back to the gem config when Rails is not defined (Rack-only usage)' do
      test = described_class.new('x')
      allow(test).to receive(:rails_defined?).and_return(false)

      gem_path = VoightKampff.root.join('config', described_class::CRAWLERS_FILENAME)
      expect(test.send(:lookup_paths)).to eq([gem_path])
    end
  end

  describe 'after the first run' do
    before { described_class.new('anything').bot? }

    it 'is fast' do
      expect(
        Benchmark.realtime do
          20.times { described_class.new('anything').bot? }
        end
      ).to be < 0.005
    end
  end
end
