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
