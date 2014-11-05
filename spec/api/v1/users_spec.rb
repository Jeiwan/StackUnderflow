require 'rails_helper'

describe 'Users API' do
  describe "GET #index" do
    let(:access_token) { create(:access_token) }
    let!(:users) { create_list(:user, 2) }
    let!(:user) { users[0] }
    
    context "when access token is absent" do
      it "returns 401 status code" do
        get '/api/v1/users', format: :json
        expect(response.status).to eq 401
      end
    end

    context "when access token is invalid" do
      it "returns 401 status code" do
        get '/api/v1/users', format: :json, access_token: '12345'
        expect(response.status).to eq 401
      end
    end

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
  end

  describe "GET #show" do
    let(:access_token) { create(:access_token) }
    let!(:users) { create_list(:user, 2) }
    let!(:user) { users[0] }

    context "when access token is absent" do
      it "returns 401 status code" do
        get "/api/v1/users/#{user.username}", format: :json
        expect(response.status).to eq 401
      end
    end

    context "when access token is invalid" do
      it "returns 401 status code" do
        get "/api/v1/users/#{user.username}", format: :json, access_token: '12345'
        expect(response.status).to eq 401
      end
    end

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
  end
end
