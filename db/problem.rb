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

  belongs_to :problem_group
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

  # method: GET, PUT, PATCH, DELETE
  def allowed?(by: nil, method:, action: "")
    return self.class.readables(user: by, action: action).to_a.one?{|x| x.id == id } if method == "GET"

    case by&.role_id
    when ROLE_ID[:admin]
      true
    when ROLE_ID[:writer]
      creator_id == by.id
    else
      false
    end
  end

  # method: GET
  scope :readables, ->(user: nil, action: "") {
    case user&.role_id
    when ROLE_ID[:admin]
      all
    when ROLE_ID[:writer]
      next all if action.empty?
      next where(creator: user) if action == "problems_comments"
      none
    when ROLE_ID[:participant]
      next none if DateTime.now <= Setting.competition_start_at

      relation =
        left_outer_joins(problem_must_solve_before: [answers: [:score]]).
        group(:id).
        where(answers: {team: [user.team, nil]})

      relation.
        having(problem_must_solve_before_id: nil).
        or(relation.having(Score.arel_table[:point].sum.gteq(
          Problem.arel_table.alias("problem_must_solve_befores_problems")[:reference_point])
        )).
        select("problem_must_solve_befores_problems.*, problems.*")
    when ROLE_ID[:viewer]
      all
    else
      none
    end
  }
end
