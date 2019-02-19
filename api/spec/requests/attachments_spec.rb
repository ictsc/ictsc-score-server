require_relative '../spec_helper.rb'

describe 'Attachments' do
  include ApiHelpers

  let(:member) { current_member || create(:member) }
  let(:other_member) { create(:member) }

  describe 'GET /api/attachments' do
    let!(:attachment) { create(:attachment, member: member) }
    let!(:attachment_by_other) { create(:attachment, member: other_member) }
    let(:response) { get '/api/attachments' }
    subject { response.status }

    by_nologin     { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_viewer      { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    context 'when contest stop' do
      before do
        allow(Config).to receive(:competition_stop).and_return(true)
      end

      subject { json_response.size }
      by_nologin     { is_expected.to eq 0 }
      by_participant { is_expected.to eq 0 }
      by_viewer      { is_expected.to eq 0 }
      by_writer      { is_expected.to eq 2 }
      by_admin       { is_expected.to eq 2 }
    end

    describe '#size' do
      subject { json_response.size }
      by_nologin     { is_expected.to eq 0 }
      by_participant { is_expected.to eq 1 }
      by_viewer      { is_expected.to eq 0 }
      by_writer      { is_expected.to eq 2 }
      by_admin       { is_expected.to eq 2 }
    end
  end

  describe 'GET /api/attachments/:id' do
    let!(:attachment) { create(:attachment, member: member) }
    let(:response) { get "/api/attachments/#{attachment.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 404 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    context 'when contest stop' do
      before do
        allow(Config).to receive(:competition_stop).and_return(true)
      end

      subject { response.status }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }
      by_writer      { is_expected.to eq 200 }
      by_admin       { is_expected.to eq 200 }
    end

    describe '#keys' do
      let(:expected_keys) { %w(id filename member_id access_token created_at updated_at) }
      subject { json_response.keys }
      by_participant { is_expected.to match_array expected_keys - %w(access_token) }
      by_writer      { is_expected.to match_array expected_keys }
      by_admin       { is_expected.to match_array expected_keys }
    end
  end

  describe 'GET /api/attachments/:id to other uploaded' do
    let!(:attachment) { create(:attachment, member: other_member) }
    let(:response) { get "/api/attachments/#{attachment.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 404 }
    by_participant { is_expected.to eq 404 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    describe '#keys' do
      let(:expected_keys) { %w(id filename member_id access_token created_at updated_at) }
      subject { json_response.keys }
      by_writer      { is_expected.to match_array expected_keys }
      by_admin       { is_expected.to match_array expected_keys }
    end
  end

  describe 'POST /api/attachments' do
    let(:attachment) { build(:attachment, member: other_member) }
    let(:file_to_upload) { Rack::Test::UploadedFile.new(__FILE__, "text/plain") }
    let(:params) do
      {
        file: file_to_upload,
        member_id: attachment.member_id
      }
    end

    describe 'create attachment' do
      let(:expected_keys) { %w(id filename member_id access_token url created_at updated_at) }
      let(:response) { post '/api/attachments', params }
      subject { response.status }

      by_nologin     { is_expected.to eq 403 }
      by_viewer      { is_expected.to eq 403 }

      all_success_block = Proc.new do
        is_expected.to eq 201
        expect(json_response.keys).to match_array expected_keys
      end

      by_participant &all_success_block
      by_writer &all_success_block
      by_admin &all_success_block

      by_writer      { expect(json_response['member_id']).to eq current_member.id }
      by_participant { expect(json_response['member_id']).to eq current_member.id }
      by_admin       { expect(json_response['member_id']).to eq other_member.id }

      context 'when contest stop' do
        before do
          allow(Config).to receive(:competition_stop).and_return(true)
        end

        by_nologin     { is_expected.to eq 403 }
        by_viewer      { is_expected.to eq 403 }
        by_participant { is_expected.to eq 403 }
        by_writer      { is_expected.to eq 201 }
        by_admin       { is_expected.to eq 201 }
      end

      describe 'GET /api/attachment/:id/:access_token' do
        let(:user) { current_member || create(:member) }
        let(:pre_post) { create(:attachment, member: user, data: file_to_upload.tempfile.open.read) }
        let(:response) { get "/api/attachments/#{pre_post['id']}/#{pre_post['access_token']}" }

        success_download_block = Proc.new do
          expect(response.status).to eq 200
          expect(response.body).to eq file_to_upload.tempfile.open.read
        end

        by_writer &success_download_block
        by_participant &success_download_block
        by_admin &success_download_block

        context 'when contest stop' do
          before do
            allow(Config).to receive(:competition_stop).and_return(true)
          end

          by_nologin     { is_expected.to eq 404 }
          by_participant { is_expected.to eq 404 }
          by_viewer      { is_expected.to eq 404 }
          by_writer      { is_expected.to eq 200 }
          by_admin       { is_expected.to eq 200 }
        end
      end
    end

    describe 'create attachment with missing file' do
      let(:params_without_file) { params.except(:file) }
      let(:response) { post '/api/attachments', params_without_file }
      subject { response.status }

      by_writer      { is_expected.to eq 400 }
      by_admin       { is_expected.to eq 400 }
    end
  end

  describe 'PUT, PATCH /api/attachments' do
    let(:attachment) { create(:attachment, member: member) }

    let(:params) do
      {
        member_id: other_member.id
      }
    end

    shared_examples 'expected success statuses' do
      subject { response.status }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }
      by_writer      { is_expected.to eq 404 }
      by_admin       { is_expected.to eq 404 }
    end

    context "PATCH" do
      let(:response) { patch "/api/attachments/#{attachment.id}", params }

      it_behaves_like 'expected success statuses'
    end

    context 'PUT' do
      let(:response) { put "/api/attachments/#{attachment.id}", params }

      it_behaves_like 'expected success statuses'
    end
  end

  describe 'DELETE /api/attachments/:id' do
    shared_examples 'expected success statuses' do
      subject { response.status }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_writer      { is_expected.to eq 204 }
      by_admin       { is_expected.to eq 204 }
    end

    describe 'oneself attachment' do
      let!(:attachment) { create(:attachment, member: member) }
      let(:response) { delete "/api/attachments/#{attachment.id}" }

      it_behaves_like 'expected success statuses'

      subject { response.status }
      by_participant { is_expected.to eq 204 }

      context 'when contest stop' do
        before { allow(Config).to receive(:competition_stop).and_return(true) }
        by_participant { is_expected.to eq 404 }
      end
    end

    describe "other's attachment" do
      let!(:attachment) { create(:attachment, member: other_member) }
      let(:response) { delete "/api/attachments/#{attachment.id}" }

      it_behaves_like 'expected success statuses'

      subject { response.status }
      by_participant { is_expected.to eq 404 }
    end
  end
end
