require_relative '../spec_helper.rb'

describe 'Teams' do
  include ApiHelpers

  describe 'GET /api/teams' do
    let(:response) { get '/api/teams' }
    subject { response.status }

    by_nologin     { is_expected.to eq 200 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    context 'when contest stop' do
      before do
        allow(Config).to receive(:competition_stop).and_return(true)
      end

      by_nologin     { is_expected.to eq 200 }
      by_viewer      { is_expected.to eq 200 }
      by_participant { is_expected.to eq 200 }
      by_writer      { is_expected.to eq 200 }
      by_admin       { is_expected.to eq 200 }
    end

    describe '#size' do
      let!(:teams) { create(:team) }
      subject { json_response.size }

      # including my team
      by_nologin     { is_expected.to eq 2 }
      by_viewer      { is_expected.to eq 2 }
      by_participant { is_expected.to eq 2 }
      by_writer      { is_expected.to eq 2 }
      by_admin       { is_expected.to eq 2 }
    end
  end

  describe 'GET /api/teams/:id' do
    let!(:team) { create(:team) }

    let(:response) { get "/api/teams/#{team.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 200 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    context 'when contest stop' do
      before do
        allow(Config).to receive(:competition_stop).and_return(true)
      end

      by_nologin     { is_expected.to eq 200 }
      by_viewer      { is_expected.to eq 200 }
      by_participant { is_expected.to eq 200 }
      by_writer      { is_expected.to eq 200 }
      by_admin       { is_expected.to eq 200 }
    end

    describe '#keys' do
      let(:expected_keys) { %w(id name organization created_at updated_at) }
      subject { json_response.keys }
      by_nologin     { is_expected.to match_array expected_keys }
      by_viewer      { is_expected.to match_array expected_keys }
      by_participant { is_expected.to match_array expected_keys }
      by_writer      { is_expected.to match_array expected_keys + %w(hashed_registration_code) }
      by_admin       { is_expected.to match_array expected_keys + %w(hashed_registration_code) }
    end
  end

  describe 'POST /api/teams' do
    let(:team) { build(:team) }
    let(:post_response_keys) { %w(id name organization created_at updated_at hashed_registration_code) }

    let(:params) do
      {
        name: team.name,
        organization: team.organization,
        registration_code: team.registration_code
      }
    end

    describe 'create team' do
      let(:response) { post '/api/teams', params }
      subject { response.status }

      by_nologin     { is_expected.to eq 403 }
      by_viewer      { is_expected.to eq 403 }
      by_participant { is_expected.to eq 403 }

      all_success_block = Proc.new do
        is_expected.to eq 201
        expect(json_response.keys).to match_array post_response_keys
      end

      by_writer &all_success_block
      by_admin &all_success_block
    end

    describe 'create team with missing name' do
      let(:params_without_name) { params.except(:name) }
      let(:response) { post '/api/teams', params_without_name }
      subject { response.status }

      by_writer  { is_expected.to eq 400 }
      by_admin   { is_expected.to eq 400 }
    end

    describe 'cannot create same registration_code' do
      let(:params1) do
        {
          name: team.name,
          organization: team.organization,
          registration_code: 'code'
        }
      end
      let(:params2) do
        {
          name: team.name,
          organization: team.organization,
          registration_code: 'code'
        }
      end
      let(:response1) { post '/api/teams', params1 }
      let(:response2) { post '/api/teams', params2 }

      by_writer do
        expect(response1.status).to eq 201
        expect(response2.status).to eq 400
      end

      by_admin do
        expect(response1.status).to eq 201
        expect(response2.status).to eq 400
      end
    end
  end

  describe 'PUT, PATCH /api/teams' do
    let!(:team) { create(:team) }
    let(:new_name) { team.name + 'nya-' }
    let(:params) do
      {
        name: new_name,
        organization: team.organization,
        registration_code: team.registration_code
      }
    end

    shared_examples 'expected statuses' do
      subject { response.status }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }
      by_writer      { is_expected.to eq 200 }
      by_admin       { is_expected.to eq 200 }
    end

    context 'PUT' do
      let(:response) { put "/api/teams/#{team.id}", params }
      it_behaves_like 'expected statuses'

      by_writer do
        expect(response.status).to eq 200
        expect(json_response['name']).to eq new_name
      end

      by_admin do
        expect(response.status).to eq 200
        expect(json_response['name']).to eq new_name
      end
    end

    context 'PUT without name' do
      let(:response) { put "/api/teams/#{team.id}", params.except(:name) }
      subject { response.status }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }
      by_writer      { is_expected.to eq 400 }
      by_admin       { is_expected.to eq 400 }
    end

    context 'PATCH without name' do
      let(:response) { patch "/api/teams/#{team.id}", params.except(:name) }
      it_behaves_like 'expected statuses'

      by_writer do
        expect(response.status).to eq 200
        expect(json_response['name']).to eq team.name
      end

      by_admin do
        expect(response.status).to eq 200
        expect(json_response['name']).to eq team.name
      end
    end

    describe 'PUT cannot create same registration_code' do
      let(:update_code_response){ put "/api/teams/#{team.id}", params.merge(registration_code: 'code') }
      let!(:team2) { create(:team) }
      let(:params2) do
        {
          name: team2.name,
          organization: team2.organization,
          registration_code: 'code'
        }
      end
      let(:response) { put "/api/teams/#{team2.id}", params2 }

      by_writer do
        expect(update_code_response.status).to eq 200
        expect(response.status).to eq 400
      end

      by_admin do
        expect(update_code_response.status).to eq 200
        expect(response.status).to eq 400
      end
    end
  end

  describe 'DELETE /api/teams/:id' do
    let!(:team) { create(:team) }

    let(:response) { delete "/api/teams/#{team.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 404 }
    by_participant { is_expected.to eq 404 }
    by_writer      { is_expected.to eq 204 }
    by_admin       { is_expected.to eq 204 }
  end
end
