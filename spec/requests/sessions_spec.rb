require_relative '../spec_helper.rb'

describe 'Sessions' do
  include ApiHelpers

  let(:member) { create(:member) }

  context 'Login with missing credential' do
    let(:params) do
      {
        login: member.login,
        password: member.password + 'hogehoge'
      }
    end

    let(:response) { post '/api/session', params }

    it_should_behave_like 'not logged in'
    it { expect(json_response).to eq ({ 'status' => 'failed' }) }
  end

  context 'Login with correct credential' do
    let (:params) do
      {
        login: member.login,
        password: member.password
      }
    end

    let(:response) { post '/api/session', params }

    it { expect(response.status).to eq 201 }
    it { expect(json_response).to eq ({ 'status' => 'success'}) }
  end
end
