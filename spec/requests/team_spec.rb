require_relative '../spec_helper.rb'

describe Team do
  include ApiHelpers

  describe 'GET /api/teams' do
    let!(:teams) { create_list(:team, 2) }

    let(:response) { get '/api/teams' }
    subject { response.status }

    by_nologin     { is_expected.to eq 200 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    describe '#size' do
      subject { json_response.size }
      by_nologin     { is_expected.to eq 2 }
      by_viewer      { is_expected.to eq 2 }
      by_participant { is_expected.to eq 3 } # including my team
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
        expect(json_response.keys).to match_array %w(id name organization created_at updated_at hashed_registration_code)
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
  end

  describe 'PUT, PATCH /api/teams' do
    let!(:team) { create(:team) }
    let(:new_name) { team.name + 'nya-' }

    describe "edit problem group" do
      let(:params) do
        {
          name: new_name,
          organization: team.organization,
          registration_code: team.registration_code
        }
      end

      shared_examples 'expected success statuses' do
        subject { response.status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 404 }
        by_writer      { is_expected.to eq 200 }
        by_admin       { is_expected.to eq 200 }
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
        it_behaves_like 'expected success statuses'

        by_writer      { expect(json_response['name']).to eq team.name }
        by_admin       { expect(json_response['name']).to eq team.name }
      end

      context 'PUT' do
        let(:response) { put "/api/teams/#{team.id}", params }
        it_behaves_like 'expected success statuses'

        by_writer      { expect(json_response['name']).to eq new_name }
        by_admin       { expect(json_response['name']).to eq new_name }
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
