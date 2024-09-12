# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ReplicantsController do
  let(:user_agent_string) { '' }

  before do
    expect_any_instance_of(ActionController::TestRequest).to receive(:user_agent).and_return user_agent_string # rubocop:disable RSpec/AnyInstance, RSpec/ExpectInHook, RSpec/StubbedMock
    get :index
  end

  HUMANS.each do |name, ua_string|
    context "when user agent is #{name}" do
      let(:user_agent_string) { ua_string }

      it 'is forbidden' do
        expect(response).to have_http_status 403
        expect(response.body).to match(/No replicants here/)
      end
    end
  end

  REPLICANTS.each do |name, ua_string|
    context "when user agent is #{name}" do
      let(:user_agent_string) { ua_string }

      it 'is successful' do
        expect(response).to have_http_status 200
        expect(response.body).to match(/Rick Deckard/)
      end
    end
  end
end
