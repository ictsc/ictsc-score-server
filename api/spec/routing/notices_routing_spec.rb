require "rails_helper"

RSpec.describe NoticesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/notices").to route_to("notices#index")
    end

    it "routes to #show" do
      expect(:get => "/notices/1").to route_to("notices#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/notices").to route_to("notices#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/notices/1").to route_to("notices#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/notices/1").to route_to("notices#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/notices/1").to route_to("notices#destroy", :id => "1")
    end
  end
end
