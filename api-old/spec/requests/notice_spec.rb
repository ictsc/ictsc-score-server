require_relative '../spec_helper.rb'

describe Notice do
  include ApiHelpers

  describe 'GET /api/notices' do
    let!(:notices) { create_list(:notice, 2) }
    let(:response) { get '/api/notices' }
    subject { response.status }

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
  end

  describe 'GET /api/notices/:id' do
    let!(:notice) { create(:notice) }
    let(:response) { get "/api/notices/#{notice.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    describe '#keys' do
      let(:expected_keys) { %w(id title text pinned member_id created_at updated_at) }
      subject { json_response.keys }
      by_viewer      { is_expected.to match_array expected_keys }
      by_participant { is_expected.to match_array expected_keys }
      by_writer      { is_expected.to match_array expected_keys }
      by_admin       { is_expected.to match_array expected_keys }
    end
  end

  describe 'POST /api/notices' do
    let(:other_member) { create(:member) }
    let(:notice) { build(:notice) }
    let(:params) do
      {
        title: notice.title,
        text: notice.text,
        pinned: false,
        member_id: other_member.id
      }
    end

    describe 'create notice' do
      let(:expected_keys) { %w(id title text pinned member_id created_at updated_at) }
      let(:response) { post '/api/notices', params }
      subject { response.status }

      by_nologin     { is_expected.to eq 403 }
      by_viewer      { is_expected.to eq 403 }
      by_participant { is_expected.to eq 403 }

      all_success_block = Proc.new do
        is_expected.to eq 201
        expect(json_response.keys).to match_array expected_keys
      end

      by_writer &all_success_block
      by_admin &all_success_block

      by_writer { expect(json_response['member_id']).to eq current_member.id }
      by_admin  { expect(json_response['member_id']).to eq other_member.id }
    end

    describe 'create notice with missing title' do
      let(:params_without_title) { params.except(:title) }
      let(:response) { post '/api/notices', params_without_title }
      subject { response.status }

      by_writer      { is_expected.to eq 400 }
      by_admin       { is_expected.to eq 400 }
    end
  end

  describe 'PUT, PATCH /api/notices' do
    let!(:member) do
      if current_member&.role == build(:role, :writer)
        current_member # writer oneself
      else
        create(:member, :writer)
      end
    end
    let(:notice) { create(:notice, member: member) }
    let(:new_title) { notice.title + 'nya-' }

    describe "edit notice" do
      let(:params) do
        {
          title: new_title,
          text: notice.text,
          pinned: false,
          member_id: notice.member_id
        }
      end

      shared_examples 'expected success statuses' do
        subject { response.status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 404 }
      end

      context 'PUT without title' do
        let(:response) { put "/api/notices/#{notice.id}", params.except(:title) }
        subject { response.status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 404 }
        by_writer      { is_expected.to eq 400 }
        by_admin       { is_expected.to eq 400 }
      end

      context "PATCH with other's member_id" do
        let(:other_member) { create(:member) }
        let(:response) { patch "/api/notices/#{notice.id}", params.merge(member_id: other_member.id) }
        subject { response.status }

        by_writer      { is_expected.to eq 400 }
        by_admin       { expect(json_response['member_id']).to eq other_member.id }
      end

      context "PATCH to other's notice can't edit other's notice" do
        let!(:member) { create(:member, :writer) }
        let(:response) { patch "/api/notices/#{notice.id}", params }
        subject { response.status }

        by_writer      { is_expected.to eq 404 }
      end

      context 'PUT' do
        let(:response) { put "/api/notices/#{notice.id}", params }
        it_behaves_like 'expected success statuses'

        by_writer      { expect(json_response['title']).to eq new_title }
        by_admin       { expect(json_response['title']).to eq new_title }

        describe "can't delete other's notice" do
          let!(:member) { create(:member, :writer) }
          subject { response.status }

          by_writer      { is_expected.to eq 404 }
        end
      end
    end
  end

  describe 'DELETE /api/notices/:id' do
    let!(:member) do
      if current_member&.role == build(:role, :writer)
        current_member # writer oneself
      else
        create(:member, :writer)
      end
    end
    let!(:notice) { create(:notice, member: member) }
    let(:response) { delete "/api/notices/#{notice.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 404 }
    by_participant { is_expected.to eq 404 }
    by_writer      { is_expected.to eq 204 }
    by_admin       { is_expected.to eq 204 }

    describe "can't delete other's notice" do
      let!(:member) { create(:member, :writer) }
      by_writer      { is_expected.to eq 404 }
    end
  end
end
