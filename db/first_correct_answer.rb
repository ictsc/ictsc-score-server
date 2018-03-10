class FirstCorrectAnswer < ActiveRecord::Base
  belongs_to :problem
  belongs_to :team
  belongs_to :answer

  validates :team,  presence: true
  validates :answer,  presence: true
  validates :problem, presence: true

  def self.readable_columns(user:, action: '')
    self.column_names
  end

  scope :reply_delay, ->() {
     where('answers.created_at <= :time', { time:  DateTime.now - Setting.answer_reply_delay_sec.seconds})
  }

  scope :readables, ->(user:, action: "") {
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]
      all
    when ROLE_ID[:participant]
      next none unless in_competition?

      rel = joins(:answer).reply_delay
      next rel if action == "for_count"

      rel.joins(:problem)
        .where(problems: { team_private: false })
        .or(rel.joins(:problem).where(problems: { team_private: true }, team: user.team))
    else
      none
    end
  }
end
