# frozen_string_literal: true

include FactoryBot::Syntax::Methods # rubocop:disable Style/MixinUsage

def create_config
  print 'creating configs...'

  configs = [
    { key: :competition_section1_start_at,  value_type: :date,    value: Time.zone.parse('2100-01-01 00:00:00') },
    { key: :competition_section1_end_at,    value_type: :date,    value: Time.zone.parse('2100-01-01 00:00:00') },
    { key: :competition_section2_start_at,  value_type: :date,    value: Time.zone.parse('2100-01-01 00:00:00') },
    { key: :competition_section2_end_at,    value_type: :date,    value: Time.zone.parse('2100-01-01 00:00:00') },
    { key: :competition_section3_start_at,  value_type: :date,    value: Time.zone.parse('2100-01-01 00:00:00') },
    { key: :competition_section3_end_at,    value_type: :date,    value: Time.zone.parse('2100-01-01 00:00:00') },
    { key: :competition_section4_start_at,  value_type: :date,    value: Time.zone.parse('2100-01-01 00:00:00') },
    { key: :competition_section4_end_at,    value_type: :date,    value: Time.zone.parse('2100-01-01 00:00:00') },

    { key: :guide_page,                     value_type: :string,  value: '' },
    { key: :grading_delay_sec,              value_type: :integer, value: 0 },
    { key: :reset_delay_sec,                value_type: :integer, value: 30 },
    { key: :hide_all_score,                 value_type: :boolean, value: true },
    { key: :realtime_grading,               value_type: :boolean, value: false },
    { key: :competition_stop,               value_type: :boolean, value: false },
    { key: :text_size_limit,                value_type: :integer, value: 8192 },
    { key: :delete_time_limit_sec,          value_type: :integer, value: 60 },
    { key: :penalty_weight,                 value_type: :integer, value: -10 },

    { key: :all_problem_force_open_at,      value_type: :date,    value: Time.zone.parse('2100-01-01 00:00:00') },
    { key: :scoreboard_hide_at,             value_type: :date,    value: Time.zone.parse('2100-01-01 00:00:00') },
    { key: :scoreboard_top,                 value_type: :integer, value: 3 },
    { key: :scoreboard_display_top_team,    value_type: :boolean, value: true },
    { key: :scoreboard_display_top_score,   value_type: :boolean, value: true },
    { key: :scoreboard_display_above_team,  value_type: :boolean, value: false },
    { key: :scoreboard_display_above_score, value_type: :boolean, value: true }
  ].map {|obj| Config.new(**obj) }

  Config.import!(configs)
  puts 'done'
  configs
end

create_config
