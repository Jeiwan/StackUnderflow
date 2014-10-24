require 'rails_helper'

RSpec.describe User, :type => :model do

  describe "validations" do
    it { is_expected.to validate_presence_of :username }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    it { is_expected.to ensure_length_of(:username).is_at_least(3).is_at_most(32) }
    it { is_expected.to allow_value("pedro", "Pedro123", "Pedro_Juan").for(:username) }
    it { is_expected.not_to allow_value("12", "$#!Pedro123", "Pedro Juan").for(:username) }
  end

  describe "associations" do
    it { is_expected.to have_many :questions }
    it { is_expected.to have_many :answers }
    it { is_expected.to have_many :comments }
    it { is_expected.to have_many :votes }
    it { is_expected.to have_many :attachments }
    it { is_expected.to have_many :identities }
  end

  describe "methods" do

    describe ".find_for_oauth" do
      let!(:user) { create(:user) }
      let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456') }

      context "when user is already registered with the provider" do
        before do
          user.identities.create(provider: auth.provider, uid: auth.uid)
        end

        it "returns the user" do
          expect(User.find_for_oauth(auth)).to eq user
        end
      end

      context "when user is not registered yet with the provider" do
        let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456', info: {email: user.email}) }

        context "when user already exists" do
          it "doesn't create a new user" do
            expect{User.find_for_oauth(auth)}.not_to change(User, :count)
          end
          it "creates a new identity" do
            expect{User.find_for_oauth(auth)}.to change(user.identities, :count).by(1)
          end
          it "creates a new identity with correct provider and uid" do
            identity = User.find_for_oauth(auth).identities.first
            expect(identity.provider).to eq auth.provider
            expect(identity.uid).to eq auth.uid
          end
          it "returns existing user" do
            expect(User.find_for_oauth(auth)).to eq user
          end
        end

        context "when user doesn't exist yet" do
          let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456', info: {email: 'test@mail.com'}) }

          it "creates a new user" do
            expect{User.find_for_oauth(auth)}.to change(User, :count)
          end
          it "creates a new identity for the user" do
            expect{User.find_for_oauth(auth)}.to change(Identity, :count)
          end
          it "creates a new idetity with correct provider and uid" do
            identity = User.find_for_oauth(auth).identities.first
            expect(identity.provider).to eq auth.provider
            expect(identity.uid).to eq auth.uid
          end
          it "sets user's email" do
            expect(User.find_for_oauth(auth).email).to eq 'test@mail.com'
          end
          it "sets username" do
            expect(User.find_for_oauth(auth).username).to eq "#{auth.provider}_#{auth.uid}"
          end
          it "returns the new user" do
            expect(User.find_for_oauth(auth)).to be_a User
          end
        end
      end
    end
  end
end
