require 'rspec'

module ApiHelpers
  # def self.included(base)
  #   base.extend(ClassMethods)
  # end

  def json_response
    JSON.parse(response.body)
  end

  # NOTE: 互換性のため(そのうち消す)
  # # override methods in Rack::Test::Session to pass session
  %i(get post put patch delete options head).each do |method|
    define_method(method) do |path, params = {}, env = {}|
    # define_method(method) do |path, params = {}, headers: {}, as: nil, &block|
      # super(path, params: params, &block)
      super(path, params: params)
      # super(path, params: params, headers: headers, as: as)
      # def get(path, params: nil, headers: {}, as: :json)
    end
  end
end

# define shared_context 'as_admin' 'as_writer' 'as_participant' 'as_viewer'
# For example:
# ```
# context do
#   include_context 'as_admin'
#   it { ... }
# end
# ```
# can be rewritten:
# ```
# context, by: :admin do
#   it { ... }
# end
# ```
# it also can write ...
# ```
# context do
#   it 'match some', by: :admin { ... }
# end
# ```
# same as ...:
# `by_participant { ... }`
%i(admin writer participant viewer).each do |role|
  # define short-hand method 'by_admin' 'by_writer' 'by_participant' 'by_viewer'
  define_method(:"by_#{role}") do |&block|
    let!(:current_member) do
      create(:member, role).tap do |m|
        puts "created #{role} : #{m.name} : #{m.team&.name}"
      end
    end

    before do
      post '/api/sessions', { login: current_member.login, password: current_member.password }
      # post('/api/sessions', params: { login: current_member.login, password: current_member.password })
    end

    it "by #{role}", by: role, &block
  end
end

def by_nologin(&block)
  it 'when not logged in', by: :nologin, &block
end

RSpec.shared_context "not_logged_in", by: :nologin do
  let!(:current_member) { nil }
end

RSpec.shared_examples 'not logged in' do
  it 'returns unauthorized' do
    expect(response.status).to eq 401
  end
end

RSpec.configure do |config|
  config.include AccountHelpers
  config.include AttributeHelpers
  config.include CompetitionHelpers
  config.include Crypt
  config.include JSONHelpers
  config.include NestedEntityHelpers
  config.include NotificationHelpers
  config.include ApiHelpers
end
