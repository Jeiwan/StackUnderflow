require 'rails_helper'

describe "Profiles API" do
  describe "GET /me" do
    context "when access token is absent" do
      it "returns 401 status code" do
        get '/api/v1/profiles/me', format: :json
        expect(response.status).to eq 401
      end
    end
    context "when access token is invalid" do
      it "returns 401 status code" do
        get '/api/v1/profiles/me', format: :json, access_token: '12345'
        expect(response.status).to eq 401
      end
    end

    context "when user is authorized" do
      let(:user) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }

      before do
        get '/api/v1/profiles/me', format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      has = %w(id reputation tiny_avatar_url username)
      hasnt = %w(encrypted_password email password)

      it_behaves_like "an API", has, hasnt, "", :user
    end
  end
end
