require 'rails_helper'

RSpec.describe Question, :type => :model do

  describe "validations" do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to ensure_length_of(:title).is_at_least(5).is_at_most(512) }
    it { is_expected.to ensure_length_of(:body).is_at_least(10).is_at_most(5000) }
  end

  describe "associations" do
    it { is_expected.to have_many :answers }
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :comments }
    it { is_expected.to have_and_belong_to_many :tags }
    it { is_expected.to have_many :attachments }
    it { is_expected.to accept_nested_attributes_for :attachments }
    it { is_expected.to have_many :votes }
    it { is_expected.to have_many :impressions }
  end

  describe "scopes" do
    let(:tags) { create_list(:tag, 3) }
    let!(:question1) { create(:question, tag_list: tags[0].name) }
    let!(:question2) { create(:question, tag_list: tags[1].name) }
    let!(:question3) { create(:question, tag_list: tags[0].name) }

    describe "tagged_with" do
      context "where questions have a tag" do
        it "sifts questions by tag name" do
          expect(Question.tagged_with(tags[0].name)).to match_array [question1, question3]
        end
      end

      context "where questions don't have a tag" do
        it "returns an empty array" do
          expect(Question.tagged_with(tags[2].name)).to eq []
        end
      end
    end

    describe "popular" do
      let(:users) { create_list(:user, 2) }

      before do
        question2.vote_up(users[0])
        question2.vote_up(users[1])
        question3.vote_up(users[0])
      end

      it "returns questions sorted by votes" do
        expect(Question.popular).to match_array [question2, question3, question1]
      end
    end

    describe "unanswered" do
      let!(:answer) { create(:answer, question: question2) }

      it "returns unanswered questions" do
        expect(Question.unanswered).to match_array [question1, question3]
      end
    end

    describe "active" do
      it "returns questions sorted by recent activity" do
        expect(Question.active).to match_array [question3, question2, question1]
      end
    end
  end

  describe "methods" do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:tags) { create_list(:tag, 2) }
    let(:question) { create(:question, tag_list: tags.map(&:name).join(","), user: user2) }
    let!(:answer2) { create(:answer, question: question) }

    describe "#has_best_answer?" do
      context "when question has a best answer" do
        let!(:answer1) { create(:answer, best: true, question: question) }

        it "has a best answer" do
          expect(question.has_best_answer?).to be
        end
      end

      context "when question has no best answer" do
        it "has no best answer" do
          expect(question.has_best_answer?).not_to be
        end
      end
    end

    describe "#tag_list" do
      it "returns question's tags separated by comma" do
        expect(question.tag_list).to eq "#{tags[0].name},#{tags[1].name}"
      end
    end

    describe "#tag_list=" do
      let(:tag_list) { question.tag_list = "some,new,tags,here" }

      it "creates new tags from a list" do
        expect{tag_list}.to change(Tag, :count).by(4)
      end

      it "sets question's tags from a list" do
        tag_list
        expect(question.tags.map(&:name).join(",")).to eq "some,new,tags,here"
      end
    end

    describe "#user_voted" do
      context "user voted up" do
        before { question.vote_up(user) }

        it "returns user's vote" do
          expect(question.user_voted(user)).to eq 1
        end
      end

      context "user voted down" do
        before { question.vote_down(user) }

        it "returns user's vote" do
          expect(question.user_voted(user)).to eq -1
        end
      end

      context "user didn't vote" do
        it "returns nil" do
          expect(question.user_voted(user)).to be_nil
        end
      end
    end

    describe "#vote_up" do
      context "when user never voted before" do
        it "increases question's votes number" do
          expect{question.vote_up(user)}.to change{question.reload.votes_sum}.by(1)
        end

        it "increases question's user reputation" do
          expect{question.vote_up(user)}.to change{question.user.reputation}.by(5)
        end
      end
      
      context "when user already voted" do
        before { question.vote_up(user) }
        
        it "doesn't increase question's votes number" do
          expect{question.vote_up(user)}.not_to change{question.reload.votes_sum}
        end

        it "doesn't increase question's user reputation" do
          expect{question.vote_up(user)}.not_to change{question.user.reload.reputation}
        end
      end
    end

    describe "#vote_down" do
      context "when user never voted before" do
        it "decreases question's votes number" do
          expect{question.vote_down(user)}.to change{question.reload.votes_sum}.by(-1)
        end
      end

      context "when user already voted" do
        before { question.vote_down(user) }
        
        it "doesn't increase question's votes number" do
          expect{question.vote_down(user)}.not_to change{question.reload.votes_sum}
        end
      end
    end

    describe "#voted_by?(user)" do
      context "when user didn't vote yet" do
        it "checks whether the user voted for the question or not" do
          expect(question.voted_by?(user)).to eq false
        end
      end
      
      context "when user already voted" do
        before do
          question.vote_up(user)
        end
        it "checks whether the user voted for the question or not" do
          expect(question.voted_by?(user)).to eq true
        end
      end
    end
  end

  describe "before_save" do
    let(:question) { create(:question, title: "Some good title", body: "Some good body", tag_list: "test,west,east") }

    it "adds current time and date to recent_activity column" do
      expect(question.recent_activity.to_s).to eq Time.zone.now.to_s
    end
  end
end
