class ActiveRecord::Base
  def self.required_fields(options = {})
    options[:include] ||= []
    options[:include].map!(&:to_sym)

    options[:exclude] ||= []
    options[:exclude].map!(&:to_sym)

    fields = self.validators
                 .select{|x| ActiveRecord::Validations::PresenceValidator === x }
                 .map(&:attributes)
                 .flatten
    fields - options[:exclude] + options[:include]
  end
end

class Team < ActiveRecord::Base
  validates :name, presence: true

  has_many :members, dependent: :nullify
  has_many :answers, dependent: :destroy
end

class Member < ActiveRecord::Base
  validates :name, presence: true
  validates :login, presence: true, uniqueness: true
  validates :hashed_password, presence: true
  validates :team, presence: true, if: Proc.new {|member| not member.team_id.nil? }
  validates :admin,           inclusion: { in: [true, false] }

  has_many :marked_scores   , foreign_key: "marker_id" , class_name: "Score"  , dependent: :nullify
  has_many :created_problems, foreign_key: "creator_id", class_name: "Problem", dependent: :destroy

  has_many :comments, dependent: :destroy
  belongs_to :team
end

class Problem < ActiveRecord::Base
  validates :title,     presence: true
  validates :text,      presence: true
  validates :opened_at, presence: true
  validates :closed_at, presence: true
  validates :creator,   presence: true

  has_many :answers,  dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :issues,   dependent: :destroy

  belongs_to :creator, required: true, foreign_key: "creator_id", class_name: "Member"
end

class Issue < ActiveRecord::Base
  validates :title,   presence: true
  validates :problem, presence: true
  validates :closed, inclusion: { in: [true, false] }

  has_many :comments, dependent: :destroy

  belongs_to :problem, required: true
end

class Answer < ActiveRecord::Base
  validates :text,    presence: true
  validates :problem, presence: true
  validates :score,   presence: true, if: Proc.new {|answer| not answer.score_id.nil? }
  validates :team,    presence: true, if: Proc.new {|answer| not answer.team_id.nil? }

  belongs_to :problem, required: true
  belongs_to :score
  belongs_to :team
end

class Score < ActiveRecord::Base
  validates :point,  presence: true
  validates :answer, presence: true
  validates :marker, presence: true

  belongs_to :answer, required: true
  belongs_to :marker, required: true, foreign_key: "marker_id", class_name: "Member"

end

class Comment < ActiveRecord::Base
  validates :text,    presence: true
  validates :member,  presence: true
  validates :problem, presence: true, if: Proc.new {|comment| not comment.problem_id.nil? }
  validates :issue,   presence: true, if: Proc.new {|comment| not comment.issue_id.nil? }
  validates :required_reply, inclusion: { in: [true, false] }

  belongs_to :member, required: true
  belongs_to :problem
  belongs_to :issue
end

