# frozen_string_literal: true

class GraphqlController < ApplicationController
  # UI側でcodeを見てエラーハンドリングする
  ERRORS = {
    unauthorized: {
      code: 'unauthorized',
      message: 'require login'
    },
    unexpected_error: {
      code: 'unexpected_error',
      message: 'unexpected error caused'
    }
  }.freeze

  # GraphQLのエンドポイントは常に200を返す
  # このルールを変える場合はUI側のエラーハンドルを再設計が必要
  def execute
    # GraphQLとして正しいエラーレスポンスを返すためrequire_loginは使わない
    # schema取得も弾かれる
    unless logged_in?
      render_error :unauthorized
      return
    end

    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = { current_team: current_team }

    # GraphQL::ExecutionErrorを継承した例外はexecute内で補足され、レスポンスのerrorsに入る
    render json: ApiSchema.execute(query, variables: variables, context: context, operation_name: operation_name), status: :ok

    # GraphQLとして正常なエラーを返すために大体の例外をキャッチする
  rescue StandardError => e
    # デバッグ用にログとBugsnagに出力
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    Bugsnag.notify(e)

    # GraphQLの仕様に従ったエラーを返す
    render_error :unexpected_error
  end

  private

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  def render_error(key)
    error = {
      message: ERRORS.fetch(key)[:message],
      locations: [],
      path: [],

      # Apollo流エラーハンドリング
      extensions: {
        code: ERRORS.fetch(key)[:code],
        # GraphQLのレスポンスのキーはcamelCase
        requestId: request.request_id
      }
    }

    # errorsはGraphQLの仕様上 配列な必要がある
    render json: { errors: [error] }, status: :ok
  end
end
