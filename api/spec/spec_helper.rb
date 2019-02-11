ENV['RACK_ENV'] = 'test'
ENV['RAILS_ENV'] ='test'

require 'bundler'
Bundler.require
Bundler.require(:test)

require_relative 'support/factory_bot'
require_relative 'support/api_helpers'
require_relative '../app'

SimpleCov.coverage_dir(File.join(ENV.fetch('CIRCLE_ARTIFACTS', App.settings.root), 'coverage'))

SimpleCov.start do
  add_filter "/spec/"
end

RSpec.configure do |config|
  config.color_mode = true
  config.tty = true
  config.include Rack::Test::Methods

  # Disable verbose default logger
  ActiveRecord::Base.logger = nil

  config.before :suite do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction

    ApiHelpers.current_users = {
      admin: FactoryBot.create(:member, :admin),
      writer: FactoryBot.create(:member, :writer),
      viewer: FactoryBot.create(:member, :viewer),
      participant: FactoryBot.create(:member, :participant),
      nologin: nil
    }

    Config.create!(key: :competition_time_day1_start_at, value_type: :date,    value: DateTime.parse('2012-09-03 10:00:00 +0900'))
    Config.create!(key: :competition_time_day1_end_at,   value_type: :date,    value: DateTime.parse('2112-09-03 18:00:00 +0900'))
    Config.create!(key: :competition_time_day2_start_at, value_type: :date,    value: DateTime.parse('2112-09-04 10:00:00 +0900'))
    Config.create!(key: :competition_time_day2_end_at,   value_type: :date,    value: DateTime.parse('2112-09-04 18:00:00 +0900'))
    Config.create!(key: :competition_stop,               value_type: :boolean, value: false)
    Config.create!(key: :problem_open_all_at,            value_type: :date,    value: DateTime.parse('2112-09-03 11:00:00 +0900'))
    Config.create!(key: :grading_delay_sec,              value_type: :integer, value: 30)
    Config.create!(key: :scoreboard_hide_at,             value_type: :date,    value: DateTime.parse('2112-09-03 12:00:00 +0900'))
    Config.create!(key: :scoreboard_top,                 value_type: :integer, value: 3)
    Config.create!(key: :scoreboard_display_top_team,    value_type: :boolean, value: true)
    Config.create!(key: :scoreboard_display_top_score,   value_type: :boolean, value: true)
    Config.create!(key: :scoreboard_display_above_team,  value_type: :boolean, value: false)
    Config.create!(key: :scoreboard_display_above_score, value_type: :boolean, value: true)
  end

  config.after :suite do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.clean
  end

  config.around :each do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

def app
  App
end
