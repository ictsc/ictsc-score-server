require 'rails_helper'

RSpec.describe "Scoreboards", type: :request do
  describe "GET /scoreboards" do
    it "works! (now write some real specs)" do
      get scoreboards_path
      expect(response).to have_http_status(200)
    end
  end
end
