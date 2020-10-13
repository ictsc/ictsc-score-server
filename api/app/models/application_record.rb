# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Readable
  self.abstract_class = true
  # daterange系もActiveSupport::TimeWithZoneにキャストする
  self.time_zone_aware_types += %i[daterange tsrange tstzrange]

  # FIXME: selectでカラムをフィルタしたレコードをGrpahQLのTypeに適用するときに必要
  # 応急処置
  def respond_to?(key, include_all = false) # rubocop:disable Style/OptionalBooleanParameter
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
    def all_models(ignore: [])
      # subclassesはautoload環境では動作しない
      models = [Answer, Attachment, Category, Config, FirstCorrectAnswer, Issue, IssueComment, Notice, Penalty, Problem, ProblemBody, ProblemEnvironment, ProblemSupplement, Score, Team].map(&:to_s)
      models - Array.wrap(ignore)
    end
  end
end
