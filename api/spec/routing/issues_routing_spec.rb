require "rails_helper"

RSpec.describe IssuesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/issues").to route_to("issues#index")
    end

    it "routes to #show" do
      expect(:get => "/issues/1").to route_to("issues#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/issues").to route_to("issues#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/issues/1").to route_to("issues#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/issues/1").to route_to("issues#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/issues/1").to route_to("issues#destroy", :id => "1")
    end
  end
end
