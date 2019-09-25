# frozen_string_literal: true

class Config < ApplicationRecord
  validates :key,        presence: true, uniqueness: true
  validates :value,      allow_empty: true, length: { maximum: 8192 }
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
    errors.add(:value, "#{value.inspect} is not castable to #{value_type}") unless self.class.castable?(self)
  end

  def reject_update_value_type
    errors.add(:value_type, "disallow to update value_type(#{value_type} to #{value_type_was})") if will_save_change_to_value_type?
  end

  # cast
  class << self
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
        raise UnhandledConfigValueType
      end
    end

    def cast!(record)
      cast(record).tap do |result|
        raise ConfigValueCastFailed, record if result.nil?
      end
    end

    def castable?(record)
      cast(record) != nil
    end
  end

  # record accessor
  class << self
    attr_reader :required_keys

    def get(key)
      # 多くの場合、1リクエスト内で複数の設定を取得するため、一括取得しキャッシュする
      cast(all.find {|config| config.key == key.to_s })
    end

    def get!(key)
      # 多くの場合、1リクエスト内で複数の設定を取得するため、一括取得しキャッシュする
      record = all.find {|config| config.key == key.to_s }
      raise ConfigKeyNotFound, key if record.nil?

      cast!(record)
    end

    def set(key, value)
      find_by(key: key)&.update(value: value)
    end

    def set!(key, value)
      find_by!(key: key).update!(value: value)
    rescue ActiveRecord::RecordNotFound
      raise ConfigKeyNotFound, key
    end

    # 設定を透過的にアクセスするためのアクセサーを定義する
    # e.g. クラス内で以下のような宣言をすると
    # record_accessor :hoge
    #
    # 以下の用に透過的に操作できる
    # puts Config.hoge
    # Config.hoge = 'fuga'
    def record_accessor(key)
      @required_keys ||= []
      @required_keys << key

      define_singleton_method(key) do
        get!(key)
      end

      define_singleton_method("#{key}=") do |value|
        set!(key, value)
      end
    end

    def valid?
      insufficient_keys.empty?
    end

    def insufficient_keys
      @required_keys.map(&:to_s) - all.pluck(:key)
    end
  end

  # helpers
  class << self
    def competition_time
      [
        [competition_section1_start_at, competition_section1_end_at],
        [competition_section2_start_at, competition_section2_end_at],
        [competition_section3_start_at, competition_section3_end_at],
        [competition_section4_start_at, competition_section4_end_at]
      ]
    end

    def competition_start_at
      competition_time.first.first
    end

    def competition_end_at
      competition_time.last.last
    end

    def competition?
      !competition_stop && competition_time.any? {|section| Time.current.between?(section.first, section.last) }
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
        all: {
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

    def delete_time_limit
      delete_time_limit_sec.seconds
    end

    def before_delete_time_limit?(datetime)
      Time.current - datetime <= Config.delete_time_limit_sec
    end

    # 構造化された設定
    def to_h
      {
        # 構造化
        scoreboard: scoreboard,
        competition_time: competition_time,

        # そのまま
        competition_stop: competition_stop,
        all_problem_force_open_at: all_problem_force_open_at,
        grading_delay_sec: grading_delay_sec,
        hide_all_score: hide_all_score,
        realtime_grading: realtime_grading,
        text_size_limit: text_size_limit,
        delete_time_limit_sec: delete_time_limit_sec,
        guide_page: guide_page
      }
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
  record_accessor :realtime_grading
  record_accessor :text_size_limit
  record_accessor :delete_time_limit_sec
  record_accessor :guide_page

  # スコアボードの表示設定
  record_accessor :scoreboard_hide_at
  record_accessor :scoreboard_top
  record_accessor :scoreboard_display_top_team
  record_accessor :scoreboard_display_top_score
  record_accessor :scoreboard_display_above_team
  record_accessor :scoreboard_display_above_score
end
