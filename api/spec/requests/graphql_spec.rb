# frozen_string_literal: true

require 'rails_helper'

# ログイン状態で/grpahqlにアクセスした場合の挙動のスペック
RSpec.describe 'GraphQL', type: :request do
  shared_examples 'succeed in sending GraphQL query' do
    it 'succeed in sending GraphQL query' do
      post(sessions_url, params: { name: current_team.name, password: current_team.password }, as: :json)
      expect(response).to have_http_status(:ok)

      post_query '{ me { id } }'
      expect(response).to have_http_status(:ok)
      expect(response_json).not_to have_gq_errors
      expect(response_json).to eq('data' => { 'me' => { 'id' => current_team.id } })
    end
  end

  context 'when logged-in as staff' do
    let(:current_team) { SessionHelpers.staff }

    include_examples 'succeed in sending GraphQL query'
  end

  context 'when logged-in as audience' do
    let(:current_team) { SessionHelpers.audience }

    include_examples 'succeed in sending GraphQL query'
  end

  context 'when logged-in as player' do
    let(:current_team) { SessionHelpers.player }

    include_examples 'succeed in sending GraphQL query'
  end

  context 'when not logged-in' do
    let(:current_team) { SessionHelpers.player }

    it 'fail in sending GraphQL query' do
      post_query '{ me { id } }'
      expect(response).to have_http_status(:ok)
      expect(response_json).to have_gq_errors('UNAUTHORIZED')
    end
  end
end
