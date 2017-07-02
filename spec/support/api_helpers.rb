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

  %w(admin writer participant viewer).each do |role|
    RSpec.shared_context "as_#{role}" do
      let!(:current_member) { create(:member, role.to_sym) }

      before do
        post '/api/session', { login: current_member.login, password: current_member.password }
      end
    end
  end

  RSpec.shared_context "not_logged_in" do
    let!(:current_member) { nil }
  end

  RSpec.shared_examples 'not logged in' do
    it 'returns unauthorized' do
      expect(response).to be_unauthorized
    end
  end
end
