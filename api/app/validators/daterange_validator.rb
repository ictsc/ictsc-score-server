# frozen_string_literal: true

class DaterangeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.is_a?(Range)
      record.errors.add(attribute, 'must be range')
      return
    end

    unless date_or_time?(value.begin)
      record.errors.add(attribute, 'range begin must be Date')
    end

    unless date_or_time?(value.end)
      record.errors.add(attribute, 'range end must be Date')
    end

    unless value.begin <= value.end
      record.errors.add(attribute, 'range begin must be lower or equal end')
    end
  end

  private

  def date_or_time?(value)
    value.is_a?(Date) || value.is_a?(Time)
  end
end
