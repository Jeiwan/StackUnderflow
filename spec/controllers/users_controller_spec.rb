require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }

  user_sign_in

  describe "GET #show" do
    before { get :show, username: user.username }
    it "returns a user" do
      expect(assigns[:user]).to eq user
    end

    it "renders show template" do
      expect(response).to render_template :show
    end
  end

  describe "PUT #update" do
    let(:new_avatar) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/features/user/new_avatar.jpg", "image/jpg") }
    let(:put_update) do
      put :update, username: user.username, user: { avatar: new_avatar }, format: :json
    end

    context "when signed in", sign_in: true do
      context "when user is current_user" do
        before { put_update }

        it "updates user" do
          expect(user.reload.avatar.path).to match /new_avatar\.jpg/
        end

        it "returns json object" do
          json = JSON.parse(response.body)
          expect(json["avatar_url"]).to match /new_avatar\.jpg/
        end

        it "returns status code 200" do
          expect(response.status).to eq 200
        end
      end

      context "when user is not current_user" do
        let(:put_update) do
          put :update, username: user2.username, user: { avatar: new_avatar }, format: :json
        end
        before { put_update }

        it "doesn't update user" do
          expect(user2.reload.avatar.path).not_to match /new_avatar\.jpg/
        end

        it "returns status code 403" do
          expect(response.status).to eq 403
        end
      end
    end

    context "when not signed in" do
      before { put_update }

      it "doesn't update user" do
        expect(user.reload.avatar.path).not_to match /new_avatar\.jpg/
      end

      it "returns status code 401" do
        expect(response.status).to eq 401
      end
    end
  end
end
