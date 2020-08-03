# frozen_string_literal: true

module RequestHelpers
  def response_json
    JSON.parse(response.body)
  end
end
