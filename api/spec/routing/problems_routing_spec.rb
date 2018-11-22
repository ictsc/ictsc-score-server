require "rails_helper"

RSpec.describe ProblemsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/problems").to route_to("problems#index")
    end

    it "routes to #show" do
      expect(:get => "/problems/1").to route_to("problems#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/problems").to route_to("problems#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/problems/1").to route_to("problems#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/problems/1").to route_to("problems#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/problems/1").to route_to("problems#destroy", :id => "1")
    end
  end
end
