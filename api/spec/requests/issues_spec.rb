require 'rails_helper'

RSpec.describe "Issues", type: :request do
  describe "GET /issues" do
    it "works! (now write some real specs)" do
      get issues_path
      expect(response).to have_http_status(200)
    end
  end
end
