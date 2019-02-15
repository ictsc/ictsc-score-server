require_relative '../spec_helper.rb'

describe 'Configs' do
  include ApiHelpers

  describe 'GET /api/configs' do
    describe 'ACL' do
      subject { get('/api/configs').status }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }
      by_writer      { is_expected.to eq 404 }
      by_admin       { is_expected.to eq 200 }
    end

    context '#size' do
      let!(:configs) { create_list(:config, 2) }
      let(:response) { get '/api/configs' }
      subject { json_response.size }

      by_admin  { is_expected.to eq Config.count }
    end
  end

  describe 'GET /api/configs/:id' do
    let!(:config) { create(:config) }
    let(:response) { get "/api/configs/#{config.id}" }

    describe 'ACL' do
      subject { response.status }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }
      by_writer      { is_expected.to eq 404 }
      by_admin       { is_expected.to eq 200 }
    end

    describe '#keys' do
      let(:expected_keys) { %w(id key value value_type created_at updated_at) }
      subject { json_response.keys }
      by_admin       { is_expected.to match_array expected_keys }
    end
  end

  describe 'POST /api/configs' do
    let!(:config) { build(:config) }
    let(:params) do
      {
        key: config.key,
        value: config.value,
        value_type: config.value_type
      }
    end
    let(:response) { post("/api/configs", params) }

    describe 'ACL' do
      subject { response.status }
      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }
      by_writer      { is_expected.to eq 404 }
      by_admin       { is_expected.to eq 201 }
    end

    context 'add new config' do
      by_admin do
        expect { response }.to change { Config.exists?(key: params[:key]) }.from(false).to(true)

        expect(json_response['key']).to eq params[:key]
        expect(json_response['value']).to eq params[:value]
        expect(json_response['value_type']).to eq params[:value_type]
      end
    end

    context 'add new config with missing parameter' do
      [:key, :value, :value_type].each do |key|
        let(:response) { post("/api/configs", params.except(key)) }
        subject { response.status }
        by_admin { is_expected.to eq 400 }
      end
    end
  end

  describe 'PUT, PATCH /api/configs' do
    let!(:config) { create(:config, :integer, value: 10) }
    let(:new_value) { 99 }
    let(:params) do
      {
        key: config.key,
        value: new_value,
        value_type: config.value_type
      }
    end

    describe 'ACL' do
      context 'PUT' do
        subject { put("/api/configs/#{config.id}", params).status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 404 }
        by_writer      { is_expected.to eq 404 }
        by_admin       { is_expected.to eq 200 }
      end

      context 'PATCH' do
        subject { patch("/api/configs/#{config.id}", params).status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 404 }
        by_writer      { is_expected.to eq 404 }
        by_admin       { is_expected.to eq 200 }
      end
    end

    describe 'update value' do
      context 'PUT' do
        let(:response) { put("/api/configs/#{config.id}", params) }

        by_admin do
          expect(response.status).to eq 200
          expect(json_response['value']).to eq new_value.to_s
        end
      end

      context 'PATCH' do
        let(:response) { patch("/api/configs/#{config.id}", params) }

        by_admin do
          expect(response.status).to eq 200
          expect(json_response['value']).to eq new_value.to_s
        end
      end
    end

    describe 'update value with not enough parameter' do
      context 'PUT' do
        let(:response) { put("/api/configs/#{config.id}", params.except(:value)) }

        by_admin do
          expect(response.status).to eq 400
        end
      end

      context 'PATCH' do
        let(:response) { patch("/api/configs/#{config.id}", params.except(:value)) }

        by_admin do
          expect(response.status).to eq 200
          expect(json_response['value']).to_not eq new_value
          expect(json_response['value']).to eq config.value
        end
      end
    end
  end

  describe 'DELETE /api/configs/:id' do
    let!(:config) { create(:config) }
    let(:response) { delete("/api/configs/#{config.id}") }

    describe 'ACL' do
      subject { response.status }
      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }
      by_writer      { is_expected.to eq 404 }
      by_admin       { is_expected.to eq 204 }
    end

    describe 'delete config' do
      subject { Config.exists?(key: config.key) }
      by_admin do
        expect { response }.to change { Config.exists?(key: config.key) }.from(true).to(false)
      end
    end
  end
end
