require 'rails_helper'

RSpec.describe Reputation, :type => :model do
  it { is_expected.to belong_to :user }

  describe "methods" do
    describe ".add_to(user, operation)" do
      let!(:user) { create(:user) }

      context "when operation is :question_vote_up" do
        it "create a new reputation with value = 5" do
          Reputation.add_to(user, :question_vote_up)
          expect(user.reputations.first.value).to eq 5
        end

        it "increments user's reputation_sum" do
          Reputation.add_to(user, :question_vote_up)
          expect(user.reload.reputation_sum).to eq 5
        end
      end

      context "when operation is :answer_vote_up" do
        it "create a new reputation with value = 10" do
          Reputation.add_to(user, :answer_vote_up)
          expect(user.reputations.first.value).to eq 10
        end
        it "increments user's reputation_sum" do
          Reputation.add_to(user, :answer_vote_up)
          expect(user.reload.reputation_sum).to eq 10
        end
      end

      context "when operation is :answer_mark_best" do
        it "create a new reputation with value = 15" do
          Reputation.add_to(user, :answer_mark_best)
          expect(user.reputations.first.value).to eq 15
        end
        it "increments user's reputation_sum" do
          Reputation.add_to(user, :answer_mark_best)
          expect(user.reload.reputation_sum).to eq 15
        end
      end

      context "when operation is invalid" do
        it "doesn't create a new reputation" do
          Reputation.add_to(user, :invalid_operation)
          expect(user.reputations).to be_empty
        end
        it "doesn't increment user's reputation_sum" do
          Reputation.add_to(user, :invalid_operation)
          expect(user.reload.reputation_sum).to eq 0
        end
      end
    end
  end
end
