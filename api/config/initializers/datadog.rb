# frozen_string_literal: true

# Docs. https://github.com/DataDog/dd-trace-rb/blob/master/docs/GettingStarted.md#rails
Datadog.configure do |c|
  c.use :rails, service_name: 'ictsc-score-server'
  # c.tracer enabled: true, hostname: ENV.fetch('DD_AGENT_HOSTNAME'), port: 8126

  c.analytics_enabled = true
end
