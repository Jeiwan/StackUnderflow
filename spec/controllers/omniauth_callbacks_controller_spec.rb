require 'rails_helper'

RSpec.describe OmniauthCallbacksController, :type => :controller do

  let(:user) {create :user}

  user_sign_in

  describe "#GET facebook" do
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
      provider: "facebook",
      uid: "12345"
    })
    let(:get_facebook) { get :facebook }

    before do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
    end

    context "when signed in", sign_in: true do
      it "creates a new identity" do
        expect{get_facebook}.to change{user.reload.identities.count}.by(1)
      end

      it "sets provider and uid for the identity" do
        get_facebook
        identity = Identity.last
        expect(identity.provider).to eq OmniAuth.config.mock_auth[:facebook].provider
        expect(identity.uid).to eq OmniAuth.config.mock_auth[:facebook].uid
      end

      it "redirects to 'logins' page" do
        get_facebook
        expect(response).to redirect_to logins_user_path(user)
      end
    end
  end
end
