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

    it "response contain 'unauthorized' error_code" do
      post_query 'me'
      expect(response_json).to have_gq_errors('unauthorized')
    end
  end

  context 'when raise unexpected error' do
    before(:each) do
      # 適当にStandardErrorを発生させる
      allow_any_instance_of(Types::QueryType).to receive(:me).and_raise(StandardError) # rubocop:disable RSpec/AnyInstance
    end

    context_as_player1 do
      it "response contain 'unexpected_error' error_code" do
        post_query 'me'
        expect(response_json).to have_gq_errors('unexpected_error')
      end
    end
  end
end
