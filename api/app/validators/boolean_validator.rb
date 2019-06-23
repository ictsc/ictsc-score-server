# frozen_string_literal: true

class BooleanValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless [true, false].include?(value)
      record.errors.add(attribute, 'must be true or false')
    end
  end
end
