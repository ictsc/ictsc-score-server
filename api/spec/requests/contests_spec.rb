require 'rails_helper'

RSpec.describe "Contests", type: :request do
  describe "GET /contests" do
    it "works! (now write some real specs)" do
      get contests_path
      expect(response).to have_http_status(200)
    end
  end
end
