# frozen_string_literal: true

class GraphqlController < ApplicationController
  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    Rails.logger.debug "---------- called: #{self}.#{__method__} L#{__LINE__}".red
    Rails.logger.debug [variables, query, operation_name].pretty_inspect.yellow

    if current_team.nil?
      head :unauthorized
      return
    end

    context = { current_team: current_team }

    # 下記のcontextはただのHashだが、Query内から見えるcontextはGraphQL::Query::Context
    Context.context = context

    render json: ApiSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end

  private

  def current_team
    # TODO: delete
    if Rails.env.development?
      return @current_team = Team.staff.first!
      # return @current_team = Team.audience.first!
      # return @current_team = Team.player.first!
    end

    @current_team = Team.find_by(id: session[:team_id])
  end

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

  def handle_error_in_development(error)
    logger.error error.message
    logger.error error.backtrace.join("\n")

    render json: { error: { message: error.message, backtrace: error.backtrace }, data: {} }, status: 500
  end
end
