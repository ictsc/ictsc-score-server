require 'rails_helper'

RSpec.describe "Notices", type: :request do
  describe "GET /notices" do
    it "works! (now write some real specs)" do
      get notices_path
      expect(response).to have_http_status(200)
    end
  end
end
