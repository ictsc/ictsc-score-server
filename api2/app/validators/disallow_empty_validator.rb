# frozen_string_literal: true

class DisallowEmptyValidator < ActiveModel::EachValidator
  # nilは良いが、emptyは不可
  def validate_each(record, attribute, value)
    if !value.nil? && value.empty?
      record.errors.add(attribute, 'must not be empty')
    end
  end
end
