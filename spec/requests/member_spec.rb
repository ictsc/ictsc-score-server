require_relative '../spec_helper.rb'

describe 'members' do
  context 'POST /api/members', by: :nologin do
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
      it { expect(json_response['role_id']).to eq member.role.id }
      it { expect(json_response).not_to include('password') }
    end

    context 'Create participant member with missing registration_code' do
      let (:member) { build(:member, :participant) }
      let (:params) do
        {
          name: member.name,
          login: member.login,
          password: member.password,
          team_id: member.team_id
        }
      end

      let(:response) { post '/api/members', params }

      it { expect(response).to be_bad_request }
    end

    context 'Create admin member' do
      let (:admin_role) { build(:role, :admin) }
      let (:member) { build(:member, :participant) }
      let (:params) do
        {
          name: member.name,
          login: member.login,
          password: member.password,
          team_id: member.team_id,
          registration_code: member.team.registration_code,
          role_id: admin_role.id
        }
      end

      let(:response) { post '/api/members', params }

      it { expect(response).to be_forbidden }
    end
  end

  context 'POST /api/members', by: :participant do
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

      it { expect(response).to be_forbidden }
    end

    context 'Create admin member' do
      let (:admin_role) { build(:role, :admin) }
      let (:member) { build(:member, :participant) }
      let (:params) do
        {
          name: member.name,
          login: member.login,
          password: member.password,
          team_id: member.team_id,
          registration_code: member.team.registration_code,
          role_id: admin_role.id
        }
      end

      let(:response) { post '/api/members', params }

      it { expect(response).to be_forbidden }
    end
  end

  context 'POST /api/members', by: :writer do
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
      it { expect(json_response['role_id']).to eq member.role.id }
      it { expect(json_response).not_to include('password') }
    end

    context 'Create participant member with missing registration_code' do
      let (:member) { build(:member, :participant) }
      let (:params) do
        {
          name: member.name,
          login: member.login,
          password: member.password,
          team_id: member.team_id
        }
      end

      let(:response) { post '/api/members', params }

      it { expect(response).to be_created }
    end

    context 'Create admin member' do
      let (:admin_role) { build(:role, :admin) }
      let (:member) { build(:member, :participant) }
      let (:params) do
        {
          name: member.name,
          login: member.login,
          password: member.password,
          team_id: member.team_id,
          registration_code: member.team.registration_code,
          role_id: admin_role.id
        }
      end

      let(:response) { post '/api/members', params }

      it { expect(response).to be_forbidden }
    end
  end

  context 'POST /api/members', by: :admin do
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
      it { expect(json_response['role_id']).to eq member.role.id }
      it { expect(json_response).not_to include('password') }
    end

    context 'Create participant member with missing registration_code' do
      let (:member) { build(:member, :participant) }
      let (:params) do
        {
          name: member.name,
          login: member.login,
          password: member.password,
          team_id: member.team_id
        }
      end

      let(:response) { post '/api/members', params }

      it { expect(response).to be_created }
    end

    context 'Create admin member' do
      let (:admin_role) { build(:role, :admin) }
      let (:member) { build(:member, :participant) }
      let (:params) do
        {
          name: member.name,
          login: member.login,
          password: member.password,
          team_id: member.team_id,
          registration_code: member.team.registration_code,
          role_id: admin_role.id
        }
      end

      let(:response) { post '/api/members', params }

      it { expect(response).to be_created }
      it { expect(json_response).to include('id', 'name', 'login', 'team_id', 'created_at', 'updated_at', 'role_id') }
      it { expect(json_response['role_id']).to eq admin_role.id }
      it { expect(json_response).not_to include('password') }
    end
  end
end
