# frozen_string_literal: true

module ConfigHelpers
  module_function

  def set_configs! # rubocop:disable Metrics/MethodLength
    Config.create!(key: :competition_section1_start_at,  value_type: :date,    value: Time.zone.parse('2012-09-03 10:00:00 +0900'))
    Config.create!(key: :competition_section1_end_at,    value_type: :date,    value: Time.zone.parse('2112-09-03 12:00:00 +0900'))
    Config.create!(key: :competition_section2_start_at,  value_type: :date,    value: Time.zone.parse('2112-09-03 13:00:00 +0900'))
    Config.create!(key: :competition_section2_end_at,    value_type: :date,    value: Time.zone.parse('2112-09-03 18:00:00 +0900'))
    Config.create!(key: :competition_section3_start_at,  value_type: :date,    value: Time.zone.parse('2112-09-04 10:00:00 +0900'))
    Config.create!(key: :competition_section3_end_at,    value_type: :date,    value: Time.zone.parse('2112-09-04 12:00:00 +0900'))
    Config.create!(key: :competition_section4_start_at,  value_type: :date,    value: Time.zone.parse('2112-09-04 13:00:00 +0900'))
    Config.create!(key: :competition_section4_end_at,    value_type: :date,    value: Time.zone.parse('2112-09-04 18:00:00 +0900'))
    Config.create!(key: :competition_stop,               value_type: :boolean, value: false)
    Config.create!(key: :all_problem_force_open_at,      value_type: :date,    value: Time.zone.parse('2112-09-03 11:00:00 +0900'))
    Config.create!(key: :grading_delay_sec,              value_type: :integer, value: 20.minutes.to_i)
    Config.create!(key: :reset_delay_sec,                value_type: :integer, value: 20.minutes.to_i)
    Config.create!(key: :hide_all_score,                 value_type: :boolean, value: false)
    Config.create!(key: :realtime_grading,               value_type: :boolean, value: true)
    Config.create!(key: :text_size_limit,                value_type: :integer, value: 8192)
    Config.create!(key: :penalty_weight,                 value_type: :integer, value: -10)
    Config.create!(key: :guide_page,                     value_type: :string,  value: Config.guide_page_default_value + Array.new(Random.rand(10..30)) { Faker::Books::Dune.quote }.join("\n"))
    Config.create!(key: :scoreboard_hide_at,             value_type: :date,    value: Time.zone.parse('2112-09-03 12:00:00 +0900'))
    Config.create!(key: :scoreboard_top,                 value_type: :integer, value: 3)
    Config.create!(key: :scoreboard_display_top_team,    value_type: :boolean, value: true)
    Config.create!(key: :scoreboard_display_top_score,   value_type: :boolean, value: true)
    Config.create!(key: :scoreboard_display_above_team,  value_type: :boolean, value: false)
    Config.create!(key: :scoreboard_display_above_score, value_type: :boolean, value: true)
  end
end
