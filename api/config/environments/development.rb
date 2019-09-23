# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  # if Rails.root.join('tmp', 'caching-dev.txt').exist?
  #   config.action_controller.perform_caching = true
  #
  #   config.cache_store = :memory_store
  #   config.public_file_server.headers = {
  #     'Cache-Control' => "public, max-age=#{2.days.to_i}"
  #   }
  # else
  #   config.action_controller.perform_caching = false
  #
  #   config.cache_store = :null_store
  # end

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Prepend all log lines with the following tags.
  config.log_tags = %i[request_id]
  config.colorize_logging = false

  # Docs. https://github.com/roidrage/lograge
  # https://github.com/fluent/fluent-logger-ruby
  # Fluent::Logger::ConsoleLogger.open(STDOUT)

  fluent_logger = Fluent::Logger::LevelFluentLogger.new(nil, host: ENV.fetch('FLUENTD_HOST'), use_nonblock: true, wait_writeable: false).tap do |fluent|
    fluent.formatter = proc do |severity, datetime, progname, message|
      # TODO: request_id や host_ip を jsonとして欲しいならthread_attr系使うかsubscriber使うか

      log = {
        level: severity,
        datetime: datetime,
        stage: Rails.env,
        service_name: 'api',
        request_id: ApplicationController.logger_payload[:request_id]
      }
      log[:message] = message if message
      log[:progname] = progname if progname

      log
    end
  end

  config.logger = ActiveSupport::TaggedLogging.new(fluent_logger)
end
