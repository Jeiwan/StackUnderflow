require 'rails_helper'

RSpec.describe TagsController, :type => :controller do
  let(:tags) { create_list(:tag, 5) }

  describe "GET #index" do
    before { get :index }

    it "returns a list of all tags" do
      expect(assigns(:tags)).to match_array tags
    end

    it "renders index template" do
      expect(response).to render_template :index
    end
  end
end
