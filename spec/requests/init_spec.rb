require_relative "../spec_helper.rb"

describe "GET /" do
  subject(:response) do
    get "/"
  end

  context "status is 200" do
    it { expect(response).to be_ok }
  end
end
