# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'applyProblemEnvironment', type: :request do
  context_as_staff do
    let(:problem) { create(:problem) }
    let(:team) { create(:team, :player) }
    let(:name) { 'great server' }
    let(:status) { 'status' }
    let(:host) { '192.168.0.1' }
    let(:user) { 'ubuntu' }
    let(:password) { 'password' }

    let(:query_string) do
      <<~GQL
        applyProblemEnvironment(input: { problemCode: "#{problem.code}", teamNumber: #{team.number},
            name: "#{name}", status: "#{status}", host: "#{host}", user: "#{user}", password: "#{password}" }) {

          problemEnvironment {
            host
            user
            password
            status
            name
            team { number }
            problem { code }
          }
        }
      GQL
    end

    it 'send problem env' do
      post_mutation query_string
      expect(response).to have_http_status(:ok)
      expect(response_json).not_to have_gq_errors

      # TODO: dataを確認
    end

    # 新規作成, 上書き
    # teamNumber,problemCodeが見つからなかった場合
    # teamNumber,problemCodeを与えなかった場合
  end
end
