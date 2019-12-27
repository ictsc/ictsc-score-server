# frozen_string_literal: true

Team.create!(role: 'staff', name: 'staff', organization: '運営', number: 999, password: ENV.fetch('API_STAFF_PASSWORD'))

seed_file = Rails.root.join('db', 'seeds', "#{Rails.env}.rb")

if File.readable?(seed_file)
  Rails.logger.debug "load seed file: #{seed_file}"
  load(seed_file)
else
  Rails.logger.debug "seed file not found: #{seed_file}"
end
