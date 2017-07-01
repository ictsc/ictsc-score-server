require_relative '../spec_helper.rb'

describe 'Members' do
  include ApiHelpers

  context 'Create participant member' do
    let (:member) { build(:member, :participant) }
    let (:params) do
      {
        name: member.name,
        login: member.login,
        password: member.password,
        team_id: member.team_id,
        registration_code: member.team.registration_code
      }
    end

    let(:response) { post '/api/members', params }

    it { expect(response).to be_created }
    it { expect(json_response).to include('id', 'name', 'login', 'team_id', 'created_at', 'updated_at', 'role_id') }
    it { expect(json_response).not_to include('password') }
  end
end
