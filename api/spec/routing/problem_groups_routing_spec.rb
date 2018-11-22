require "rails_helper"

RSpec.describe ProblemGroupsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/problem_groups").to route_to("problem_groups#index")
    end

    it "routes to #show" do
      expect(:get => "/problem_groups/1").to route_to("problem_groups#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/problem_groups").to route_to("problem_groups#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/problem_groups/1").to route_to("problem_groups#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/problem_groups/1").to route_to("problem_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/problem_groups/1").to route_to("problem_groups#destroy", :id => "1")
    end
  end
end
