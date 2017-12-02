# Make settings could be read via `Setting.hogefuga`
class Setting
  include Singleton

  ENV_PREFIX = 'API_CONTEST_'

  INTEGER_VALUES = %w(
    answer_reply_delay_sec
    scoreboard_viewable_top
  )

  DATETIME_VALUES = %w(
    competition_start_at
    scoreboard_hide_at
    competition_end_at
  )

  REQUIRED_KEYS = %w(
    redis_realtime_notification_channel
  ) + INTEGER_VALUES + DATETIME_VALUES

  REQUIRED_KEYS.each do |key|
    env_key = ENV_PREFIX + key.upcase

    begin
      env_value = ENV.fetch(env_key)
    rescue KeyError
      STDERR.puts "ENV '#{env_key}' not defined, aborting."
      exit 1
    end

    value = case key
      when *INTEGER_VALUES then env_value.to_i
      when *DATETIME_VALUES then DateTime.parse(env_value)
      else env_value
      end

    define_singleton_method(key.to_sym) { value }
  end
end
