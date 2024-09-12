# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VoightKampff do
  subject { described_class }

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
