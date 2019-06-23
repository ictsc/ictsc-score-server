# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:current_team) { create(:team, :staff) }

  shared_examples 'succeed in login and logout' do
    it 'succeed in login and logout' do
      post sessions_url, params: { name: current_team.name, password: current_team.password }, as: :json
      expect(response).to have_http_status(:ok)

      delete sessions_url, as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when team is staff' do
    let(:current_team) { create(:team, :staff) }

    include_examples 'succeed in login and logout'
  end

  context 'when current team is audience' do
    let(:current_team) { create(:team, :audience) }

    include_examples 'succeed in login and logout'
  end

  context 'when current team is player' do
    let(:current_team) { create(:team, :player) }

    include_examples 'succeed in login and logout'
  end

  context 'when current team is non-existent team' do
    let(:current_team) { build_stubbed(:team, :player) }

    it 'fail in login' do
      post sessions_url, params: { name: current_team.name, password: current_team.password }, as: :json
      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'when extra parameters' do
    let(:current_team) { build_stubbed(:team, :player) }

    it 'fail in login' do
      post sessions_url, params: { name: current_team.name, password: current_team.password, foobar: 'foobar' }, as: :json
      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'when not logged-in' do
    it 'fail in logout' do
      delete sessions_url, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
