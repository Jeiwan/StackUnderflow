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
    it { is_expected.to have_many :reputations }
    it { is_expected.to have_many :favorite_questions }
  end

  describe "scopes" do
    let!(:users) { create_list(:user, 3) }

    before do
      users[0].update(username: "bbb", reputation_sum: 5)
      users[2].update(username: "aaa", reputation_sum: 10)
      users[1].update(username: "ccc", reputation_sum: 15)
    end

    describe "by_reputation" do
      it "returns users sorted by reputation in descending order" do
        expect(User.by_reputation).to match_array [users[1], users[2], users[0]]
      end
    end

    describe "by_registration" do
      it "returns users sorted by registration in descending order" do
        expect(User.by_registration).to match_array [users[2], users[1], users[0]]
      end
    end

    describe "alphabetically" do
      it "returns users sorted alphabetically in descending order" do
        expect(User.alphabetically).to match_array [users[2], users[0], users[1]]
      end
    end
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

    describe "#reputations_chart_date" do
      let!(:user) { create(:user) }
      before do
        user.reputations.create(value: 10)
        user.reputations.create(value: 5, created_at: 2.days.ago)
        user.reputations.create(value: 10, created_at: 15.days.ago)
        user.reputations.create(value: 15, created_at: 29.days.ago)
        user.reputations.create(value: 30, created_at: 30.days.ago)
      end

      it "returns formated data for reputations chart" do
        result = user.reputations_chart_data
        expect(result[29][:date]).to eq Date.today
        expect(result[29][:reputation]).to eq 10
        expect(result[29][:percentage]).to eq 66.67

        expect(result[27][:date]).to eq 2.days.ago.to_date
        expect(result[27][:reputation]).to eq 5
        expect(result[27][:percentage]).to eq 33.33

        expect(result[14][:date]).to eq 15.days.ago.to_date
        expect(result[14][:reputation]).to eq 10
        expect(result[14][:percentage]).to eq 66.67

        expect(result[0][:date]).to eq 29.days.ago.to_date
        expect(result[0][:reputation]).to eq 15
        expect(result[0][:percentage]).to eq 100
      end
    end

    describe "#has_favorite?(questions)" do
      let(:user) { create(:user) }
      let(:question) { create(:question) }

      context "when questions is in the user's favorite list" do
        before { user.add_favorite(question.id) }
        it "returns true" do
          expect(user.reload.has_favorite?(question.id)).to eq true
        end
      end
      context "when questions is not in the user's favorite list" do
        it "returns false" do
          expect(user.has_favorite?(question.id)).to eq false
        end
      end
    end

    describe "#add_favorite(question_id)" do
      let(:user) { create(:user) }
      let(:question) { create(:question) }

      it "adds question to user's favorite questions" do
        expect{user.add_favorite(question.id)}.to change{user.favorite_questions.count}.by(1)
      end
    end

    describe "#remove_favorite(question_id)" do
      let(:user) { create(:user) }
      let(:question) { create(:question) }

      before do
        user.add_favorite(question.id)
      end
      
      it "removes question from user's favorite questions" do
        expect{user.remove_favorite(question.id)}.to change{user.favorite_questions.count}.by(-1)
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
