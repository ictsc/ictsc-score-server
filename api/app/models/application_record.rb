# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Readable
  self.abstract_class = true
  # daterange系もActiveSupport::TimeWithZoneにキャストする
  self.time_zone_aware_types += %i[daterange tsrange tstzrange]

  # FIXME: selectでカラムをフィルタしたレコードをGrpahQLのTypeに適用するときに必要
  # 応急処置
  def respond_to?(key, include_all = false)
    if self.class.column_names.include?(key.to_s)
      true
    else
      super
    end
  end

  def public_send(key, *args)
    super
  rescue ActiveModel::MissingAttributeError
    nil
  end

  class << self
    def models(ignore: [])
      # subclassesはautoload環境では動作しない
      [Answer, Attachment, Category, Config, FirstCorrectAnswer, Issue, IssueComment, Notice, Problem, ProblemBody, ProblemEnvironment, ProblemSupplement, Score, Team] - [*ignore]
    end
  end
end
