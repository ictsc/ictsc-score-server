class FirstCorrectAnswer < ActiveRecord::Base
  belongs_to :problem
  belongs_to :team

  validates :team,  presence: true
  validates :problem, presence: true, uniqueness: true
end