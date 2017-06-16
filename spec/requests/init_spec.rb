require_relative "../spec_helper.rb"

describe "GET /" do
  subject(:response) do
    get "/"
  end

  # index page is provided by ui component, outside of this app
  context "status is 404" do
    it { expect(response).to be_not_found }
  end
end

describe "Member" do
  subject(:response) { post "/api/members", params }

  let (:params) do
    {
      name: "user",
      login: "user",
      password: "test",
      team_id: 1,
      registration_code: "team1"
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
