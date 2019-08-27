# frozen_string_literal: true

class HealthController < ApplicationController
  def health
    head :ok
  end
end
