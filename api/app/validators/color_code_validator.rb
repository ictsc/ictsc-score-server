# frozen_string_literal: true

class ColorCodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # 小文字を許すとUI側の変更チェックが手間になる
    unless /\A\#[A-F0-9]{6}\z/.match?(value)
      record.errors.add(attribute, 'must be upper case color code (e.g. #E91A4F )')
    end
  end
end
