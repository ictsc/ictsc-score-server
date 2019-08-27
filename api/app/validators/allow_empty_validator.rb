# frozen_string_literal: true

class AllowEmptyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.nil?
      record.errors.add(attribute, 'must not be nil')
    end
  end
end
