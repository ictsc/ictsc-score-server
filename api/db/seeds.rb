# frozen_string_literal: true

Team.create!(role: 'staff', name: Team.special_team_name_staff, beginner: false, organization: '運営', color: '#FFFFFF', number: 999, secret_text: '', password: ENV.fetch('API_STAFF_PASSWORD'))
Team.create!(role: 'player', name: Team.special_team_name_team99, beginner: false, organization: '運営', color: '#FFFFFF', number: 99, secret_text: '', password: ENV.fetch('API_STAFF_PASSWORD'))

seed_file = Rails.root.join('db', 'seeds', "#{Rails.env}.rb")

if File.readable?(seed_file)
  Rails.logger.debug "load seed file: #{seed_file}"
  load(seed_file)
else
  Rails.logger.debug "seed file not found: #{seed_file}"
end
