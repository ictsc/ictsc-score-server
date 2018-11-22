require 'rails_helper'

RSpec.describe "ProblemGroups", type: :request do
  describe "GET /problem_groups" do
    it "works! (now write some real specs)" do
      get problem_groups_path
      expect(response).to have_http_status(200)
    end
  end
end
