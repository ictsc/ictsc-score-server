require 'rspec'

module ApiHelpers
  def json_response
    JSON.parse(response.body)
  end

  def session
    begin
      { 'rack.session' => last_request.env['rack.session'] }
    rescue Rack::Test::Error # raises if no request before
      {}
    end
  end

  # override methods in Rack::Test::Session to pass session
  %i(get post put patch delete options head).each do |method|
    define_method(method) do |uri, params = {}, env = {}, &block|
      env.merge! session
      super(uri, params, env, &block)
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
%w(admin writer participant viewer).each do |role|
  RSpec.shared_context "as_#{role}", by: role.to_sym do
    include ApiHelpers
    let!(:current_member) { create(:member, role.to_sym) }

    before do
      post '/api/session', { login: current_member.login, password: current_member.password }
    end
  end
  
  # define short-hand method 'by_admin' 'by_writer' 'by_participant' 'by_viewer'
  define_method("by_#{role}".to_sym) do |&block|
    it "by #{role}", by: role.to_sym, &block
  end
end

RSpec.shared_context "not_logged_in", by: :nologin do
  include ApiHelpers
  let!(:current_member) { nil }
end

def by_nologin(&block)
  it 'when not logged in', by: :nologin, &block
end

RSpec.shared_examples 'not logged in' do
  it 'returns unauthorized' do
    expect(response.status).to eq 401
  end
end
