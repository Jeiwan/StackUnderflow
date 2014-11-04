require 'rails_helper'

describe 'Users API' do
  describe "GET #index" do
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
      let(:access_token) { create(:access_token) }
      let!(:users) { create_list(:user, 2) }
      let!(:user) { users[0] }

      before do
        get '/api/v1/users', format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      it "returns users list" do
        expect(response.body).to have_json_size(2)
      end

      %w(id location medium_avatar_url reputation username).each do |attr|
        it "returns user #{attr}" do
          if user.respond_to?(attr.to_sym)
            expect(response.body).to be_json_eql(user.send(attr.to_sym).to_json).at_path("0/#{attr}")
          else
            expect(response.body).to have_json_path("0/#{attr}")
          end
        end
      end
    end
  end

  describe "GET #show" do
    let(:user) { create(:user) }

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
      let(:access_token) { create(:access_token) }
      let!(:users) { create_list(:user, 2) }
      let!(:user) { users[0] }

      before do
        get "/api/v1/users/#{user.username}", format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      %w(age full_name id location medium_avatar_url reputation small_avatar_url tiny_avatar_url username website).each do |attr|
        it "returns user #{attr}" do
          if user.respond_to?(attr.to_sym)
            expect(response.body).to be_json_eql(user.send(attr.to_sym).to_json).at_path(attr)
          else
            expect(response.body).to have_json_path(attr)
          end
        end
      end
    end
  end
end
