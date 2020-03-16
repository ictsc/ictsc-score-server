# frozen_string_literal: true

class Config < ApplicationRecord
  validates :key,        presence: true, uniqueness: true
  # 空文字列とfalseは許可. nil不可
  validates :value,      presence: false
  validates :value_type, presence: true
  validate :validate_value
  validate :reject_update_value_type, on: :update

  enum value_type: {
    boolean: 10,
    integer: 20,
    string: 30,
    date: 40
  }

  def validate_value
    errors.add(:value, "#{value.inspect} is not #{value_type}") unless self.valid_value?
  end

  def reject_update_value_type
    errors.add(:value_type, "disallow to update value_type(#{value_type} to #{value_type_was})") if will_save_change_to_value_type?
  end

  def value
    if self.date?
      Time.zone.parse(self[:value])
    else
      self[:value]
    end
  end

  def valid_value? # rubocop:disable Metrics/CyclomaticComplexity
    return false if self[:value].nil?

    case self.value_type
    when 'boolean'
      self[:value] == true || self[:value] == false
    when 'integer'
      self[:value].is_a?(Integer)
    when 'string'
      self[:value].is_a?(String)
    when 'date'
      Time.zone.parse(self[:value]).present? rescue false # rubocop:disable Style/RescueModifier
    else
      raise UnhandledConfigValueType
    end
  end

  # record accessor
  class << self
    attr_reader :required_keys

    # 多くの場合、1リクエスト内で複数の設定を取得するため、一括取得しキャッシュする
    def find_by_key?(key)
      all.find {|config| config.key == key.to_s }
    end

    def get(key)
      find_by_key?(key)&.value # rubocop:disable Rails/DynamicFindBy
    end

    def get!(key)
      record = find_by_key?(key) # rubocop:disable Rails/DynamicFindBy
      raise ConfigKeyNotFound, key if record.nil?

      record.value
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

    def sufficient?
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
        all: { # for self record
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

    def guide_page_default_value
      <<~STR
        全てのテキストエリアでMarkdownが使えます。
        ドラッグ&ドロップでファイルをアップロードできます。
        テキストエリア右下にプレビューボタンがあります。

      STR
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
        reset_delay_sec: reset_delay_sec,
        hide_all_score: hide_all_score,
        realtime_grading: realtime_grading,
        text_size_limit: text_size_limit,
        guide_page: guide_page,
        penalty_weight: penalty_weight
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
  record_accessor :reset_delay_sec
  record_accessor :hide_all_score
  record_accessor :realtime_grading # 有効解答を最終解答にするか最高得点にするかもこれで指定
  record_accessor :text_size_limit
  record_accessor :guide_page
  record_accessor :penalty_weight

  # スコアボードの表示設定
  record_accessor :scoreboard_hide_at
  record_accessor :scoreboard_top
  record_accessor :scoreboard_display_top_team
  record_accessor :scoreboard_display_top_score
  record_accessor :scoreboard_display_above_team
  record_accessor :scoreboard_display_above_score
end
