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

      %w(id reputation tiny_avatar_url username).each do |attr|
        it "returns user #{attr}" do
          if user.respond_to?(attr.to_sym)
            expect(response.body).to be_json_eql(user.send(attr.to_sym).to_json).at_path(attr)
          else
            expect(response.body).to have_json_path(attr)
          end
        end
      end

      %w(encrypted_password email password).each do |attr|
        it "doesn't return user #{attr}" do
          expect(response.body).not_to have_json_path(attr)
        end
      end
    end
  end
end
