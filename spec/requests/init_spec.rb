require_relative "../spec_helper.rb"

describe "GET /" do
  subject(:response) do
    get "/"
  end

  context "status is 200" do
    it { expect(response).to be_ok }
  end
end

describe "Member" do
  subject(:response) { post "/api/members", params }

  let (:params) do
    {
      name: "user",
      login: "user",
      password: "test",
      role_id: 4
    }
  end

  context "Create member" do
    it { expect(response).to be_created }
  end
end

describe "Session" do
  context "Login with missing credential" do
    subject(:response) do
      post "/api/session", params
    end

    let(:params) do
      {
        login: "user",
        password: "test2"
      }
    end

    let(:parsed_response) { response; JSON.parse(response.body) }

    it { expect(parsed_response).to eq ({ "status" => "failed"}) }
  end

  context "Login with correct credential" do
    subject(:response) do
      post "/api/session", params
    end

    let (:params) do
      {
        login: "user",
        password: "test"
      }
    end

    let(:parsed_response) { response; JSON.parse(response.body) }

    it { expect(parsed_response).to eq ({ "status" => "success"}) }
  end
end
