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

  describe 'when not logged in' do
    let(:response) { get '/api/session' }

    let (:expected_response) {
      {
        'status' => 'not_logged_in',
        'logged_in' => false,
        'notification_channels' => {
          'all' => 'everyone'
        }
      }
    }

    it { expect(response.status).to eq 200 }
    it { expect(json_response).to eq expected_response }
  end

  context 'Login with correct credential' do
    let (:params) do
      {
        login: member.login,
        password: member.password
      }
    end

    let (:expected_response) {
      {
        'status' => 'success',
        'notification_channels' => {
          'member' => member&.notification_subscriber&.channel_id,
          'team' => member&.team&.notification_subscriber&.channel_id,
          'role' => member&.role&.notification_subscriber&.channel_id,
          'all' => 'everyone'
        }.compact,
        'member' => member.as_json(except: [:hashed_password])
      }.as_json
    }

    let(:response) { post '/api/session', params }

    it { expect(response.status).to eq 201 }
    it { expect(json_response).to eq expected_response }
  end
end
