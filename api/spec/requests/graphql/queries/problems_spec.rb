# frozen_string_literal: true

require 'rails_helper'

# テストするのは1段目のネストのみ

RSpec.describe 'problems', type: :request do
  context_as_staff do
    it 'get problems' do
      # TODO: impl
      post_query 'problems'
    end
  end

  # context_as_staff do
  #   # 全てのprobem, env, supplements, body, issue, issue-comment, answer, answer-scoreを取得できる
  # end
  #
  # context_as_audience do
  #   # 全ての問題を取得できる
  # end
  #
  # context_as_player do
  # end
end
