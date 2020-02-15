# frozen_string_literal: true

class ColorCodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.empty?

    unless /\A\#[A-F0-9]{6}\z/i.match?(value)
      record.errors.add(attribute, 'must be color code (e.g. #e91a4f )')
    end
  end
end
