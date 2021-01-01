# frozen_string_literal: true

require 'rails_helper'

# ログインしてから/graphqlにクエリを投げてレスポンスを取得するまでを保証する
RSpec.describe 'GraphQL', type: :request do
  shared_examples 'succeed spec' do
    it 'succeed in sending GraphQL query' do
      # FactoryBotで作成したため password == name
      post sessions_url, params: { name: current_team.name, password: current_team.name }, as: :json
      expect(response).to have_http_status(:ok)

      post_query 'me'
      expect(response_json).not_to have_gq_errors
      expect(response_gql.fetch('id')).to eq(current_team.id)
    end
  end

  context 'when logged-in as staff' do
    let(:current_team) { staff }

    include_examples 'succeed spec'
  end

  context 'when logged-in as audience' do
    let(:current_team) { audience }

    include_examples 'succeed spec'
  end

  context 'when logged-in as player1' do
    let(:current_team) { player1 }

    include_examples 'succeed spec'
  end

  context 'when not logged-in' do
    let(:current_team) { nil }

    it 'fail in sending GraphQL query' do
      post_query 'me'
      expect(response_json).to have_gq_errors('UNAUTHORIZED')
    end
  end
end
