require_relative '../spec_helper.rb'

describe 'Members' do
  before :context do
    Team.create(name: "team1", registration_code: "team1")
  end

  let (:params) do
    {
      name: 'user',
      login: 'user',
      password: 'test',
      team_id: 1,
      registration_code: 'team1'
    }
  end

  let(:response) { post '/api/members', params }

  context 'Create member' do
    it { expect(response).to be_created }
  end
end
