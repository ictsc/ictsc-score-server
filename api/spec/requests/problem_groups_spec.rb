require_relative '../spec_helper.rb'

describe 'ProblemGroups' do
  include ApiHelpers

  describe 'GET /api/problem_groups' do
    let!(:problem_group) { create_list(:problem_group, 2) }

    describe 'while competition' do
      let(:response) { get '/api/problem_groups' }
      subject { response.status }

      before(:each) {
        time = DateTime.parse("2017-07-07T21:00:00+09:00")
        allow(DateTime).to receive(:current).and_return(time)
        allow(Config).to receive(:competition_start_at).and_return(time - 3.year)
      }

      by_nologin     { is_expected.to eq 200 }
      by_viewer      { is_expected.to eq 200 }
      by_participant { is_expected.to eq 200 }
      by_writer      { is_expected.to eq 200 }
      by_admin       { is_expected.to eq 200 }

      describe '#size' do
        subject { json_response.size }
        by_nologin     { is_expected.to eq 0 }
        by_viewer      { is_expected.to eq 2 }
        by_participant { is_expected.to eq 2 }
        by_writer      { is_expected.to eq 2 }
        by_admin       { is_expected.to eq 2 }
      end

      let(:expected_keys) { %w(id description name problem_ids completing_bonus_point icon_url visible created_at updated_at order) }
      describe '#keys for problem_groups' do
        let(:json_response_problem) { json_response.first }
        subject { json_response_problem.keys }

        by_viewer      { is_expected.to match_array expected_keys }
        by_participant { is_expected.to match_array expected_keys }
        by_writer      { is_expected.to match_array expected_keys }
        by_admin       { is_expected.to match_array expected_keys }
      end
    end

    describe 'before start competition' do
      let(:response) { get '/api/problem_groups' }
      subject { response.status }

      before(:each) {
        time = DateTime.parse('2012-09-03 10:00:00 +0900')
        allow(DateTime).to receive(:current).and_return(time - 1.minute)
        allow(Config).to receive(:competition_time_day1_start_at).and_return(time)
      }

      by_nologin     { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_writer      { is_expected.to eq 200 }
      by_admin       { is_expected.to eq 200 }

      describe '#size' do
        subject { json_response.size }
        # by_nologin     { is_expected.to eq 0 }
        # by_participant { is_expected.to eq 0 }
        # by_viewer      { is_expected.to eq 2 }
        by_writer      { is_expected.to eq 2 }
        by_admin       { is_expected.to eq 2 }
      end
    end
  end

  describe 'GET /api/problem_groups/:id' do
    let!(:problem_group) { create(:problem_group) }

    describe 'while competition' do
      let(:response) { get "/api/problem_groups/#{problem_group.id}" }
      subject { response.status }

      before(:each) {
        time = DateTime.parse("2017-07-07T21:00:00+09:00")
        allow(DateTime).to receive(:current).and_return(time)
        allow(Config).to receive(:competition_start_at).and_return(time - 3.year)
      }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 200 }
      by_participant { is_expected.to eq 200 }
      by_writer      { is_expected.to eq 200 }
      by_admin       { is_expected.to eq 200 }

      describe '#keys' do
       let(:expected_keys) { %w(id description name problem_ids completing_bonus_point icon_url visible created_at updated_at order) }
        subject { json_response.keys }

        by_viewer      { is_expected.to match_array expected_keys }
        by_participant { is_expected.to match_array expected_keys }
        by_writer      { is_expected.to match_array expected_keys }
        by_admin       { is_expected.to match_array expected_keys }
      end
    end

    describe 'before start competition' do
      let(:response) { get "/api/problem_groups/#{problem_group.id}" }
      subject { response.status }

      before(:each) {
        time = DateTime.parse('2012-09-03 10:00:00 +0900')
        allow(DateTime).to receive(:current).and_return(time - 1.minute)
        allow(Config).to receive(:competition_time_day1_start_at).and_return(time)
      }

      by_nologin     { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_writer      { is_expected.to eq 200 }
      by_admin       { is_expected.to eq 200 }
    end
  end

  describe 'POST /api/problem_groups' do
    let(:problem_group) { build(:problem_group) }

    let(:params) do
      {
        name: problem_group.name,
        description: problem_group.description,
        completing_bonus_point: 42,
        order: 20,
      }
    end

    describe 'create problem_group' do
      let(:response) { post '/api/problem_groups', params }
      subject { response.status }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }

      all_success_block = Proc.new do
        is_expected.to eq 201
        expect(json_response.keys).to match_array %w(id description name problem_ids completing_bonus_point icon_url visible created_at updated_at order)
      end

      by_writer &all_success_block
      by_admin &all_success_block
    end

    describe 'create problem_group with missing name' do
      let(:params_without_name) { params.except(:name) }
      let(:response) { post '/api/problem_groups', params_without_name }
      subject { response.status }

      by_writer  { is_expected.to eq 400 }
      by_admin   { is_expected.to eq 400 }
    end
  end

  describe 'PUT, PATCH /api/problem_groups' do
    let!(:problem_group) { create(:problem_group) }
    let(:new_name) { problem_group.name + 'nya-' }

    describe "edit problem group" do
      let(:params) do
        {
          name: new_name,
          description: problem_group.description,
          completing_bonus_point: problem_group.completing_bonus_point,
          visible: problem_group.visible,
          order: 20,
          icon_url: problem_group.icon_url
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
        let(:response) { put "/api/problem_groups/#{problem_group.id}", params.except(:name) }
        subject { response.status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 404 }
        by_writer      { is_expected.to eq 400 }
        by_admin       { is_expected.to eq 400 }
      end

      context 'PATCH without name' do
        let(:response) { patch "/api/problem_groups/#{problem_group.id}", params.except(:name) }
        it_behaves_like 'expected success statuses'

        by_writer      { expect(json_response['name']).to eq problem_group.name }
        by_admin       { expect(json_response['name']).to eq problem_group.name }
      end

      context 'PUT' do
        let(:response) { put "/api/problem_groups/#{problem_group.id}", params }
        it_behaves_like 'expected success statuses'

        by_writer      { expect(json_response['name']).to eq new_name }
        by_admin       { expect(json_response['name']).to eq new_name }
      end
    end
  end

  describe 'DELETE /api/problem_groups/:id' do
    let!(:problem_group) { create(:problem_group) }

    let(:response) { delete "/api/problem_groups/#{problem_group.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 404 }
    by_participant { is_expected.to eq 404 }
    by_writer      { is_expected.to eq 204 }
    by_admin       { is_expected.to eq 204 }
  end
end
