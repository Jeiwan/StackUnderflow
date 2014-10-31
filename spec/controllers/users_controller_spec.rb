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

  describe "GET #edit" do

    context "when signed in", sign_in: true do
      context "when user edits his profile" do
        before do
          get :edit, username: user.username
        end

        it "assigns @user variable" do
          expect(assigns(:user)).to eq user
        end
        it "renders edit template" do
          expect(response).to render_template :edit
        end
      end

      context "when user edits not his profile" do
        before do
          get :edit, username: user2.username
        end

        it "assigns @user variable" do
          expect(assigns(:user)).to eq user2
        end
        it "redirects to root path" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when not signed in" do
      before do
        get :edit, username: user.username
      end

      it "redirects to sign in page" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PUT #update" do
    let(:new_avatar) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/features/user/new_avatar.jpg", "image/jpg") }
    let(:put_update) do
      put :update, username: user.username, user: { username: user.username.reverse, avatar: new_avatar }, format: :json
    end

    context "when signed in", sign_in: true do
      context "when user is current_user" do
        before { put_update }

        it "updates user's avatar" do
          expect(user.reload.avatar.path).to match /new_avatar\.jpg/
        end

        it "updates user's username" do
          expect(user.username.reverse).to eq user.reload.username
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
          put :update, username: user2.username, user: { avatar: new_avatar, username: user2.username.reverse }, format: :json
        end
        before { put_update }

        it "doesn't update user" do
          expect(user2.reload.avatar.path).not_to match /new_avatar\.jpg/
          expect(user2.username.reverse).not_to eq user2.reload.username
        end

        it "returns status code 401" do
          expect(response.status).to eq 401
        end
      end
    end

    context "when not signed in" do
      before { put_update }

      it "doesn't update user" do
        expect(user.reload.avatar.path).not_to match /new_avatar\.jpg/
        expect(user2.reload.username).not_to eq user.username.reverse
      end

      it "returns status code 401" do
        expect(response.status).to eq 401
      end
    end
  end
end
