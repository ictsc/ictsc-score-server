# frozen_string_literal: true

# rubocop:disable Style/FormatStringToken

# TODO: Configはいろいろ無駄なので作り直す
class Config < ApplicationRecord
  class CastFailed < StandardError; end

  validates :key,        presence: true, uniqueness: true
  validates :value,      presence: true, length: { maximum: 8192 }
  validates :value_type, presence: true
  validate :validate_castable
  validate :reject_update_value_type, on: :update

  enum value_type: {
    boolean: 10,
    integer: 20,
    string: 30,
    date: 40
  }

  def validate_castable
    errors.add(:value, ' "%s" is not castable to %s' % [value, value_type]) unless self.class.castable?(self)
  end

  def reject_update_value_type
    errors.add(:value_type, 'disallow to update value_type(%s to %s)' % [value_type, value_type_was]) if will_save_change_to_value_type?
  end

  class << self
    def get(key)
      cast(find_by(key: key))
    end

    def get!(key)
      cast!(find_by!(key: key))
    end

    def set(key, value)
      find_by(key: key)&.update(value: value)
    end

    def set!(key, value)
      find_by!(key: key).update!(value: value)
    end

    def cast(record) # rubocop:disable Metrics/CyclomaticComplexity
      return nil if record&.value_type.nil?

      case record
      when :boolean?.to_proc
        case record.value
        when 'true', 't', '1' then true
        when 'false', 'f', '0' then false
        else nil
        end
      when :integer?.to_proc
        Integer(record.value, exception: false)
      when :string?.to_proc
        record.value
      when :date?.to_proc
        Time.zone.parse(record.value) rescue nil # rubocop:disable Style/RescueModifier
      else
        nil
      end
    end

    def cast!(record)
      result = cast(record)
      raise CastFailed, 'key: %s, value: "%s", value_type: %s' % [record.key, record.value, record.value_type] if result.nil?

      result
    end

    def castable?(record)
      cast(record) != nil
    end
  end

  # record accessor
  class << self
    attr_reader :required_keys

    def record_accessor(key)
      @required_keys ||= []
      @required_keys << key
      var_name = "@#{key}"

      define_singleton_method(key) do
        # キャッシュすると永続する
        # return instance_variable_get(var_name) if instance_variable_defined?(var_name)
        instance_variable_set(var_name, get!(key))
      end

      define_singleton_method("#{key}=") do |value|
        set!(key, value)
        instance_variable_set(var_name, get!(key))
      end
    end

    def competition_time
      [
        { start_at: competition_section1_start_at, end_at: competition_section1_end_at },
        { start_at: competition_section2_start_at, end_at: competition_section2_end_at },
        { start_at: competition_section3_start_at, end_at: competition_section3_end_at },
        { start_at: competition_section4_start_at, end_at: competition_section4_end_at }
      ]
    end

    def competition_start_at
      competition_time.first[:start_at]
    end

    def competition_end_at
      competition_time.last[:end_at]
    end

    def scoreboard
      {
        hide_at: scoreboard_hide_at,
        top: scoreboard_top,
        display: scoreboard_display
      }
    end

    def scoreboard_display
      {
        all: { # staff and current team
          team: true,
          score: true
        },
        top: {
          team: scoreboard_display_top_team,
          score: scoreboard_display_top_score
        },
        above: {
          team: scoreboard_display_above_team,
          score: scoreboard_display_above_score
        }
      }
    end

    # 構造化された設定
    def to_h
      {
        competition_time: competition_time,
        competition_stop: competition_stop,
        all_problem_force_open_at: all_problem_force_open_at,
        grading_delay_sec: grading_delay_sec,
        scoreboard: scoreboard
      }
    end

    def competition?
      !competition_stop && competition_time.any? {|day| Time.current.between?(day[:start_at], day[:end_at]) }
    end
  end

  # 1日目午前, 午後, ...
  record_accessor :competition_section1_start_at
  record_accessor :competition_section1_end_at
  record_accessor :competition_section2_start_at
  record_accessor :competition_section2_end_at
  record_accessor :competition_section3_start_at
  record_accessor :competition_section3_end_at
  record_accessor :competition_section4_start_at
  record_accessor :competition_section4_end_at

  record_accessor :competition_stop
  record_accessor :all_problem_force_open_at
  record_accessor :grading_delay_sec
  record_accessor :hide_all_score

  record_accessor :scoreboard_hide_at
  record_accessor :scoreboard_top

  record_accessor :scoreboard_display_top_team
  record_accessor :scoreboard_display_top_score
  record_accessor :scoreboard_display_above_team
  record_accessor :scoreboard_display_above_score
end

# rubocop:enable Style/FormatStringToken
