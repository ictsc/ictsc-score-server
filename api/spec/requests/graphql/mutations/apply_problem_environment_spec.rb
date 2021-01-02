# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'applyProblemEnvironment', type: :request do
  context_as_staff do
    let(:problem) { create(:problem) }
    let(:team) { create(:team, :player) }
    let(:env) { build(:problem_environment, team: team, problem: problem) }
    let(:input) do
      {
        problemCode: env.problem.code,
        teamNumber: env.team.number,
        name: env.name,
        service: env.service,
        status: env.status,
        host: env.host,
        port: env.port,
        user: env.user,
        password: env.password,
        secretText: env.secret_text
      }
    end

    it 'send problem env' do
      post_mutation(input: input)
      expect(response_json).not_to have_gql_errors

      # TODO: dataを確認
    end

    # 新規作成, 上書き
    # teamNumber,problemCodeが見つからなかった場合
    # teamNumber,problemCodeを与えなかった場合
  end
end
