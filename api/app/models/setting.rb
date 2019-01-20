# frozen_string_literal: true

# Make settings could be read via `Setting.hogefuga`
class Setting
  include Singleton

  ENV_PREFIX = 'API_CONTEST_'

  # scoreboard_viewable_top 上位Nチームを公開
  INTEGER_VALUES = %w(
    answer_reply_delay_sec
    scoreboard_viewable_top
  ).freeze

  # scoreboard_viewable_*  公開する情報(チーム名 スコア)
  BOOLEAN_VALUES = %w(
    scoreboard_viewable_top_show_team
    scoreboard_viewable_top_show_score
    scoreboard_viewable_up_show_team
    scoreboard_viewable_up_show_score
  ).freeze

  DATETIME_VALUES = %w(
    competition_start_at
    scoreboard_hide_at
    competition_end_at
  ).freeze

  REQUIRED_KEYS = %w(
    redis_realtime_notification_channel
  ) + INTEGER_VALUES + DATETIME_VALUES + BOOLEAN_VALUES

  REQUIRED_KEYS.each do |key|
    env_key = ENV_PREFIX + key.upcase

    begin
      env_value = ENV.fetch(env_key)
    rescue KeyError
      STDERR.puts "ENV '#{env_key}' not defined, aborting."
      exit 1
    end

    value = case key
            when *INTEGER_VALUES  then env_value.to_i
            when *DATETIME_VALUES then DateTime.parse(env_value)
            when *BOOLEAN_VALUES  then env_value == 'true'
            else                       env_value
            end

    define_singleton_method(key.to_sym) { value }
  end

  # スコアボードの公開する情報をRubyから扱いやすく
  def self.scoreboard_viewable_config
    {
      all: {
        team: true,
        score: true,
      },
      top: {
        team: scoreboard_viewable_top_show_team,
        score: scoreboard_viewable_top_show_score,
      },
      up: {
        team: scoreboard_viewable_up_show_team,
        score: scoreboard_viewable_up_show_score,
      },
    }
  end
end
