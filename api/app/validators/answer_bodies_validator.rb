# frozen_string_literal: true

class AnswerBodiesValidator < ActiveModel::EachValidator
  # Answer#bodiesとProblemBody#correctsに適用する
  # フォーマットの詳細は該当スペックを参照
  def validate_each(record, attribute, value) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # 選択式の共通部分
    validate_structure = proc do
      if !value.is_a?(Array) || value.empty? || !value.all?(Array)
        # nil, '', 10, []
        record.errors.add(attribute, "in #{record.mode} mode, #{attribute} must be [[String, ...], ...]")
        return
      elsif value.any? {|list| list.any? {|elem| !elem.is_a?(String) || elem.empty? } }
        # [[10]], [['']]
        record.errors.add(attribute, "in #{record.mode} mode, #{attribute} elements must be none empty string")
        return
      elsif value.size != record.candidates.size
        record.errors.add(attribute, "#{attribute} size must be same as candidates size")
        return
      end
    end

    case record.mode
    when 'textbox'
      case record
      when Answer
        unless value.is_a?(Array) && value.size == 1 &&
               value.first.is_a?(Array) && value.first.size == 1 &&
               value.first.first.is_a?(String) && !value.first.first.empty?

          record.errors.add(attribute, "in #{record.mode} mode, #{attribute} must be [[String]]")
        end
      when ProblemBody
        record.errors.add(attribute, "in #{record.mode} mode, #{attribute} must be []") unless value == []
      else
        raise UnhandledClass, record
      end
    when 'radio_button'
      # [['foo'], ...]

      # データ構造的バリデーション
      validate_structure.call

      # 意味的バリデーション
      if value.any? {|list| list.size != 1 }
        # ラジオボタンなので必ず1つのみ
        # [['foo', 'bar']], [[]]
        record.errors.add(attribute, "in #{record.mode} mode, each #{attribute} elements size must be one")
      elsif value.zip(record.candidates).any? {|list, candidate| candidate.exclude?(list.first) }
        # 解答が存在しない選択肢なら
        record.errors.add(attribute, "in #{record.mode} mode, #{attribute} must be included in candidates")
      end
    when 'checkbox'
      # [[], ...], [['foo'], ...], [['foo', 'bar', ...], ...]

      # データ構造的バリデーション
      validate_structure.call

      # 意味的バリデーション
      if value.zip(record.candidates).any? {|list, candidate| list.size > candidate.size }
        # 正解の数が選択肢の数を上回ったら
        record.errors.add(attribute, "in #{record.mode} mode, each #{attribute} elements size must be less than or equal to candidate element size")
      elsif value.zip(record.candidates).any? {|list, candidate| !(list - candidate).empty? }
        # 解答に存在しない選択肢が含まれていたら
        record.errors.add(attribute, "in #{record.mode} mode, #{attribute} must be included in candidates")
      elsif value.any? {|list| list.size != list.uniq.size }
        # 解答内の選択肢が重複してたら
        record.errors.add(attribute, "in #{record.mode} mode, #{attribute} must be unique")
      end
    else
      raise UnhandledProblemBodyMode, record.mode
    end
  end
end
