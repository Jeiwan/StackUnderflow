require 'rails_helper'

RSpec.describe User, :type => :model do

  describe "validations" do
    it { is_expected.to validate_presence_of :username }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    it { is_expected.to ensure_length_of(:username).is_at_least(3).is_at_most(64) }
    it { is_expected.to allow_value("pedro", "Pedro123", "Pedro_Juan").for(:username) }
    it { is_expected.not_to allow_value("12", "$#!Pedro123", "Pedro Juan").for(:username) }
    it { is_expected.to validate_numericality_of :age }
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

      context "when user is not registered with the provider" do
        it "creates a user" do
          expect{User.find_for_oauth(auth)}.to change(User, :count).by(1)
        end
        it "returns the user" do
          expect(User.find_for_oauth(auth)).to be_a User
        end
        it "sets user's email" do
          expect(User.find_for_oauth(auth).email).to eq "#{auth.provider}_#{auth.uid}@stackunderflow.dev"
        end
        it "sets user's username" do
          expect(User.find_for_oauth(auth).username).to eq "#{auth.provider}_#{auth.uid}"
        end
        it "sets user's status to 'without_email'" do
          expect(User.find_for_oauth(auth).status).to eq "without_email"
        end
        it "creates a new identity" do
          expect{User.find_for_oauth(auth)}.to change(Identity, :count).by(1)
        end
        it "sets correct provider and uid to the identity" do
          identity = User.find_for_oauth(auth).identities.first
          expect(identity.provider).to eq auth.provider
          expect(identity.uid).to eq auth.uid
        end
      end
    end
  end

  describe "after_update" do
    let!(:user) { create(:user, status: 0) }

    context "when unconfirmed_email was changed" do
      it "sets the user's status to 'pending'" do
        user.unconfirmed_email = "some_new@email.com"
        user.save
        expect(user.reload.status).to eq "pending"
      end
    end
    context "when unconfirmed_email wasn't changed" do
      it "doesn't set the user's status to 'pending'" do
        expect(user.status).to eq "guest"
      end
    end
  end
end
