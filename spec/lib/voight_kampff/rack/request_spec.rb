# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rack::Request do
  subject { described_class.new(env) }

  let(:user_agent_string) {} # rubocop:disable Lint/EmptyBlock
  let(:env) { { 'HTTP_USER_AGENT' => user_agent_string } }

  it { expect(subject).to respond_to :human? }
  it { expect(subject).to respond_to :bot? }
  it { expect(subject).to respond_to :replicant? }

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
end
