# frozen_string_literal: true

module Mutations
  class ApplyProblem < BaseMutation
    field :problem,      Types::ProblemType,     null: true
    field :problem_body, Types::ProblemBodyType, null: true

    argument :code,                  String,                        required: true
    argument :category_code,         String,                        required: false
    argument :previous_problem_code, String,                        required: false
    argument :order,                 Integer,                       required: true
    argument :team_isolate,          Boolean,                       required: true
    argument :open_at_begin,         Types::DateTime,               required: false
    argument :open_at_end,           Types::DateTime,               required: false
    argument :writer,                String,                        required: true
    argument :secret_text,           String,                        required: true

    # body
    argument :mode,                  Types::Enums::ProblemBodyMode, required: true
    argument :title,                 String,                        required: true
    argument :genre,                 String,                        required: true
    argument :text,                  String,                        required: true
    argument :perfect_point,         Integer,                       required: true
    argument :solved_criterion,      Integer,                       required: true
    argument :candidates,            [[String]],                    required: true
    argument :corrects,              [[String]],                    required: true

    # 通知無効
    argument :silent,                Boolean,                       required: false

    # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    def resolve(code:, category_code: nil, previous_problem_code: nil,
                order:, team_isolate:, open_at_begin: nil, open_at_end: nil,
                writer:, secret_text:,
                mode:, title:, genre:, text:, perfect_point:, solved_criterion:, candidates: nil, corrects: nil,
                silent: false)

      Acl.permit!(mutation: self, args: {})

      unless category_code.nil?
        category = Category.find_by(code: category_code)
        raise RecordNotExists.new(Category, code: category_code) if category.nil?
      end

      unless previous_problem_code.nil?
        previous_problem = Problem.find_by(code: previous_problem_code)
        raise RecordNotExists.new(Problem, code: previous_problem_code) if previous_problem.nil?
      end

      problem = Problem.find_or_initialize_by(code: code)
      problem_body = problem.body || ProblemBody.new

      # attributes(params) → save と update(params) は等価ではない(トランザクション周り)
      problem_body.attributes = { mode: mode, title: title, genre: genre, text: text, perfect_point: perfect_point, solved_criterion: solved_criterion, candidates: candidates, corrects: corrects }

      open_at = open_at_begin...open_at_end if open_at_begin.present? && open_at_end.present?

      # ここでproblem_bodyも保存される
      if problem.update(body: problem_body, category: category, previous_problem: previous_problem, order: order, team_isolate: team_isolate, open_at: open_at, writer: writer, secret_text: secret_text)
        # regrade_answersに失敗するとエラーが追加される
        add_errors(problem_body) if problem_body.errors.key?(:regrade_answers)

        Notification.notify(mutation: self.graphql_name, record: problem) unless silent
        { problem: problem.readable(team: self.current_team!), problem_body: problem_body.readable(team: self.current_team!) }
      else
        add_errors(problem, problem_body)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
  end
end
