require 'rails_helper'

describe 'Users API' do
  describe "GET #index" do
    let(:access_token) { create(:access_token) }
    let!(:users) { create_list(:user, 2) }
    let!(:user) { users[0] }
    
    it_behaves_like "an authenticatable API"

    context "when user is authorized" do
      before do
        get '/api/v1/users', format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      it "returns users list" do
        expect(response.body).to have_json_size(2)
      end

      has = %w(id location medium_avatar_url reputation username)
      hasnt = %w(tiny_avatar_url small_avatar_url website age full_name)
      path = "0/"

      it_behaves_like "an API", has, hasnt, path, :user
    end

    def request_json(options = {})
      get "/api/v1/users", {format: :json}.merge(options)
    end
  end

  describe "GET #show" do
    let(:access_token) { create(:access_token) }
    let!(:users) { create_list(:user, 2) }
    let!(:user) { users[0] }

    it_behaves_like "an authenticatable API"

    context "when user is authorized" do
      before do
        get "/api/v1/users/#{user.username}", format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      has = %w(age full_name id location medium_avatar_url reputation small_avatar_url tiny_avatar_url username website)

      it_behaves_like "an API", has, nil, "", :user
    end

    def request_json(options = {})
      get "/api/v1/users/#{user.username}", {format: :json}.merge(options)
    end
  end

  describe "GET #profile" do
    it_behaves_like "an authenticatable API"

    context "when user is authorized" do
      let(:user) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }

      before do
        get '/api/v1/profile', format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      has = %w(id reputation tiny_avatar_url username website age location)
      hasnt = %w(encrypted_password email password)

      it_behaves_like "an API", has, hasnt, "", :user
    end

    def request_json(options = {})
      get "/api/v1/profile", {format: :json}.merge(options)
    end
  end
end
