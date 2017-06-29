require_relative '../spec_helper.rb'

describe 'Sessions' do
  include ApiHelpers

  before do
    Member.create(
      name: 'user',
      login: 'user',
      hashed_password: '$6$E0vkOJZbzmdof$TUzyWkvyz.NjuzpFpUtOnCoPzMaemfRuRaWdyJnMcWvmaL2RFTyclRsCsid4LxkC/N4g.N5iGmLrtj1Ib0NmE.',
      role_id: 4
    )
  end

  context 'Login with missing credential' do
    let(:params) do
      {
        login: 'user',
        password: 'test2'
      }
    end

    let(:response) { post '/api/session', params }
    # let(:parsed_response) { response; JSON.parse(response.body) }

    it { expect(response.status).to eq 401 }
    it { expect(json_response).to eq ({ 'status' => 'failed' }) }
  end

  context 'Login with correct credential' do

    let (:params) do
      {
        login: 'user',
        password: 'test'
      }
    end

    let(:response) { post '/api/session', params }

    it { expect(response.status).to eq 201 }
    it { expect(json_response).to eq ({ 'status' => 'success'}) }
  end
end
