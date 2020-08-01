# frozen_string_literal: true

class UnhandledNotificationTarget < StandardError
  def initialize(to)
    super("unhandled notification target #{to.inspect}")
  end
end
