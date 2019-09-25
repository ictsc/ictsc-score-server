# frozen_string_literal: true

# e.g.
#   expect(response_json).to have_gq_errors
#   expect(response_json).to_not have_gq_errors
#   expect(response_json).to have_gq_errors('UNAUTHORIZED')
RSpec::Matchers.define :have_gq_errors do |expected|
  match do |json|
    next false if !json.key?('errors') || json['errors'].empty?

    if expected.present?
      json['errors'].any? {|error| error.dig('extensions', 'code') == expected }
    else
      true
    end
  end
end
