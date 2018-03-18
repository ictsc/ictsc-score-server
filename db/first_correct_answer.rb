class FirstCorrectAnswer < ActiveRecord::Base
  belongs_to :problem
  belongs_to :team
  belongs_to :answer

  validates :team,  presence: true
  validates :answer,  presence: true
  validates :problem, presence: true

  def self.readable_columns(user:, action: '', reference_keys: true)
    self.all_column_names(reference_keys: reference_keys)
  end

  scope :filter_columns, ->(user:, action: '') {
    cols = readable_columns(user: user, action: action, reference_keys: false)
    next none if cols.empty?
    select(*cols)
  }

  scope :readable_records, ->(user:, action: '') {
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]
      all
    when ROLE_ID[:participant]
      next none unless in_competition?

      rel_delayed = joins(:answer).merge(Answer.reply_delay)
      case action
      when 'for_count'
        rel_delayed
      when 'opened_problem'
        rel = rel_delayed.joins(:problem)
        rel
          .where(problems: { team_private: false })
          .or(rel.where(problems: { team_private: true }, team: user.team))
      else
        rel_delayed.where(team: user.team)
      end
    else
      none
    end
  }

  # method: GET
  scope :readables, ->(user:, action: '') {
    readable_records(user: user, action: action)
      .filter_columns(user: user, action: action)
  }
end
