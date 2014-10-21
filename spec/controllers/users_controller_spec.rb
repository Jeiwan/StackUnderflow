require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  let(:user) { create(:user) }

  describe "GET #show" do
    before { get :show, id: user.username }
    it "returns a user" do
      expect(assigns[:user]).to eq user
    end

    it "renders show template" do
      expect(response).to render_template :show
    end
  end

end
