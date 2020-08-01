# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

if ENV['CIRCLECI'] || ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start('rails')
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each {|f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# Disable verbose default logger
ActiveRecord::Base.logger = nil

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config| # rubocop:disable Metrics/BlockLength
  config.include FactoryBot::Syntax::Methods
  config.include SessionHelpers
  config.include RequestHelpers

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before(:suite) do # rubocop:disable Metrics/BlockLength
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)

    # 余り意味がないので使わない
    # FactoryBot.lint(traits: true, verbose: true)

    SessionHelpers.set_teams!

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
    Config.create!(key: :grading_delay_sec,              value_type: :integer, value: 30)
    Config.create!(key: :reset_delay_sec,                value_type: :integer, value: 30)
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

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.after(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
end
