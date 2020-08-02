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

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include GraphqlHelpers
  config.include RequestHelpers
  config.extend SessionHelpers
  config.include_context SessionHelpers.define_let

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before(:suite) do
    # テスト開始前に全削除
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction

    # 余り意味がないので使わない
    # FactoryBot.lint(traits: true, verbose: true)

    SessionHelpers.set_teams!
    ConfigHelpers.set_configs!
  end

  # :allはトップレベルでしかトランザクションを貼らないなど複雑なので使用しない

  # example単位でロールバック
  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end

  # テスト終了後に全削除
  config.after(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
end
