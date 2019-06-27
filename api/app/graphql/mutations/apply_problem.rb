# frozen_string_literal: true

module Mutations
  class ApplyProblem < GraphQL::Schema::RelayClassicMutation
    field :problem, Types::ProblemType, null: true
    field :errors, [String], null: false

    argument :code, String, required: true
    argument :category_code, String, required: false
    argument :previous_problem_code, String, required: false
    argument :order, Integer, required: true
    argument :team_isolate, Boolean, required: true
    argument :open_at_begin, Types::DateTime, required: false
    argument :open_at_end, Types::DateTime, required: false
    argument :writer, String, required: false
    argument :secret_text, String, required: false

    # body
    argument :mode, Types::Enums::ProblemBodyMode, required: true
    argument :title, String, required: true
    argument :text, String, required: true
    argument :perfect_point, Integer, required: true
    argument :candidates, [[String]], required: false
    argument :corrects, [[String]], required: false

    def resolve(code:, category_code: nil, previous_problem_code: nil,
                order:, team_isolate:, open_at_begin: nil, open_at_end: nil,
                writer: nil, secret_text: '',
                mode:, title:, text:, perfect_point:, candidates:, corrects:)

      Acl.permit!(mutation: self, args: {})

      category = Category.find_by!(code: category_code) unless category_code.nil?
      previous_problem = Problem.find_by!(code: previous_problem_code) unless previous_problem_code.nil?

      problem = Problem.find_or_initialize_by(code: code)
      problem_body = problem.body || ProblemBody.new

      # attributes(params) → save と update(params) は等価ではない(トランザクション周り)
      problem_body.attributes = { mode: mode, title: title, text: text, perfect_point: perfect_point, candidates: candidates, corrects: corrects }

      # TODO: shuffle: true
      #   リロードする度にシャッフルされるのは鬱陶しい  -> あまり意味のある実装にはならなそうなのでやらない
      #   登録するときにシャッフルすれば良いかも(force shuffle) -> これ
      #   シャッフルしてほしくない問題もあるかもしれない -> UIで送信時にシャッフルすれば良さそう

      # ここでproblem_bodyも保存される
      if problem.update(body: problem_body, category: category, previous_problem: previous_problem, order: order, team_isolate: team_isolate, open_at: (open_at_begin...open_at_end), writer: writer, secret_text: secret_text)
        { problem: problem.readable, errors: [] }
      else
        { errors: problem.errors.full_messages + problem_body.errors.full_messages }
      end
    rescue StandardError => e
      raise GraphQL::ExecutionError, e.message
    end
  end
end
