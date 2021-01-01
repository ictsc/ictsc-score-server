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

    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = { current_team: current_team }

    # GraphQL::ExecutionErrorを継承した例外はexecute内で補足され、レスポンスのerrorsに入る
    result_json = ApiSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result_json, status: :ok
  rescue StandardError => e
    # GraphQLとして正常なエラーを返すために大体の例外をキャッチする

    # デバッグ用にログとBugsnagに出力
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    Bugsnag.notify(e)

    # GraphQLの仕様に従ったエラーを返す
    render_error :unexpected_error
  end

  private

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
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
