require 'rails_helper'

RSpec.describe TagsController, :type => :controller do
  let(:tags) { create_list(:tag, 5) }

  describe "GET #index" do
    get :index

    it "returns a list of all tags" do
      expect(assigns(:tags)).to match_array tags
    end

    it "renders index template" do
      expect(response).to render_template :index
    end
  end

  #describe "POST #create" do
    #context "when signed in" do
      #context "with valid data" do
        #it "creates a new tag" do
        #end
      #end

      #context "with invalid data" do
      #end
    #end

    #context "when not signed in" do
    #end
  #end
end
