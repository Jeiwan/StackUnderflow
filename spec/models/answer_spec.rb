require 'rails_helper'

RSpec.describe Answer, :type => :model do

  describe "validations" do
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to ensure_length_of(:body).is_at_least(10).is_at_most(5000) }
  end

  describe "associations" do
    it { is_expected.to belong_to :question }
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :comments }
    it { is_expected.to have_many :attachments }
    it { is_expected.to have_many :votes }
    it { is_expected.to accept_nested_attributes_for :attachments }
  end

  describe "instance methods" do
    let(:user) { create(:user) }
    let(:question) { create(:question, user: user) }
    let!(:answer) { create(:answer, question: question) }

    describe "#mark_best!" do
      context "when question has no best answer" do
        it "marks answer as best" do
          answer.mark_best!
          expect(answer).to be_best
        end
      end

      context "when question has a best answer" do
        let!(:best_answer) { create(:answer, question: question, best: true) }

        it "doesn't mark answer as best" do
          answer.mark_best!
          expect(answer).not_to be_best
        end
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
        it "increases answer's votes number" do
          expect{answer.vote_up(user)}.to change{answer.reload.votes_sum}.by(1)
        end
      end
      
      context "when user already voted" do
        before { answer.vote_up(user) }
        
        it "doesn't increase answer's votes number" do
          expect{answer.vote_up(user)}.not_to change{answer.reload.votes_sum}
        end
      end
    end

    describe "#vote_down" do
      context "when user never voted before" do
        it "decreases answer's votes number" do
          expect{answer.vote_down(user)}.to change{answer.reload.votes_sum}.by(-1)
        end
      end

      context "when user already voted" do
        before { answer.vote_down(user) }
        
        it "doesn't increase answer's votes number" do
          expect{answer.vote_down(user)}.not_to change{answer.reload.votes_sum}
        end
      end
    end

    describe "#voted_by?(user)" do
      context "when user didn't vote yet" do
        it "checks whether the user voted for the answer or not" do
          expect(answer.voted_by?(user)).to eq false
        end
      end
      
      context "when user already voted" do
        before do
          answer.vote_up(user)
        end
        it "checks whether the user voted for the answer or not" do
          expect(answer.voted_by?(user)).to eq true
        end
      end
    end
  end

  describe "after_save" do
    let(:question) { create(:question) }
    let(:answer) { build(:answer, question: question) }

    it "updates question's activity" do
      expect{answer.save}.to change(question, :recent_activity)
    end
  end
end
