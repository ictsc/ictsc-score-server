class Problem < ActiveRecord::Base
  validates :title,     presence: true
  validates :text,      presence: true
  validates :creator,   presence: true
  validates :reference_point, presence: true
  validates :perfect_point,   presence: true

  has_many :answers,  dependent: :destroy
  has_many :comments, dependent: :destroy, as: :commentable
  has_many :issues,   dependent: :destroy
  has_many :next_problems, class_name: self.to_s, foreign_key: "problem_must_solve_before_id"
  has_many :first_correct_answer, dependent: :destroy

  has_and_belongs_to_many :problem_groups, dependent: :nullify

  belongs_to :problem_must_solve_before, class_name: self.to_s
  belongs_to :creator, foreign_key: "creator_id", class_name: "Member"

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      true
    else
      false
    end
  end

  def readable?(by: nil, action: '')
    self.class.readables(user: by, action: action).exists?(id: id)
  end

  # method: GET, PUT, PATCH, DELETE
  def allowed?(by: nil, method:, action: "")
    return readable?(by: by, action: action) if method == 'GET'

    case by&.role_id
    when ROLE_ID[:admin]
      true
    when ROLE_ID[:writer]
      creator_id == by.id
    else
      false
    end
  end

  # 権限によって許可するパラメータを変える
  def self.allowed_nested_params(user:)
    base_params = %w(answers answers-score answers-team issues issues-comments comments problem_groups)
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]
      base_params + %w(creator)
    when ROLE_ID[:participant]
      base_params
    else
      %w()
    end
  end

  def self.readable_columns(user:, action: '')
    self.column_names
  end

  # 解放済み問題で得られる情報
  scope :opened_problem_info, -> () {
    select(*%w(id title text perfect_point team_private order problem_must_solve_before_id created_at updated_at))
  }

  # 未開放問題で得られる情報
  scope :not_opened_problem_info, -> () {
    select(*%w(id team_private order problem_must_solve_before_id created_at updated_at))
  }

  # method: GET
  scope :readables, -> (user:, team: nil, action: "") {
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:viewer]
      all
    when ROLE_ID[:writer]
      next all if action.empty?
      next where(creator: user) if action == "problems_comments"
      none
    when ->(role_id) { role_id == ROLE_ID[:participant] || team }
      next none unless in_competition?

      fca_problem_ids = FirstCorrectAnswer.readables(user: user, action: action).map(&:problem_id)
      where(problem_must_solve_before_id: fca_problem_ids + [nil])
        .opened_problem_info
    else
      none
    end
  }

  def readable_teams
    Team.select{|team| Problem.readables(team: team).find_by(id: id) }
  end
end
