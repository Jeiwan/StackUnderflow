require 'rails_helper'
RSpec.shared_examples "guest abilities" do
  it { is_expected.to be_able_to :read, Question }
  it { is_expected.to be_able_to :read, Answer }
  it { is_expected.to be_able_to :read, Comment }
  it { is_expected.to be_able_to :read, User }
  it { is_expected.to be_able_to :read, Tag }

  it { is_expected.not_to be_able_to :manage, :all }
end

RSpec.shared_examples "without email abilities" do
  it { is_expected.to be_able_to :update, user }
  it { is_expected.to be_able_to :read, user }
  it { is_expected.to be_able_to :profile, user }

  it { is_expected.not_to be_able_to :update, user2 }
end

describe Ability do
  subject(:ability) { Ability.new(user) }
  let(:user) { nil }

  describe "guest" do
    it_behaves_like "guest abilities"
  end

  describe "without_email" do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }

    before { user.without_email! }

    it_behaves_like "guest abilities"
    it_behaves_like "without email abilities"
  end

  describe "pending" do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }

    before { user.pending! }

    it_behaves_like "guest abilities"
    it_behaves_like "without email abilities"
  end

  describe "regular" do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:question) { create(:question, user: user) }
    let(:question2) { create(:question, user: user2) }
    let(:answer) { create(:answer, question: question, user: user) }
    let(:answer2) { create(:answer, question: question2, user: user2) }
    let(:comment) { create(:question_comment, commentable: question, user: user) }
    let(:comment2) { create(:question_comment, commentable: question2, user: user2) }
    let(:attachment) { create(:attachment, attachable: question, user: user) }
    let(:attachment2) { create(:attachment, attachable: question2, user: user2) }
    let(:identity) { create(:identity, user: user) }
    let(:identity2) { create(:identity, user: user2) }

    before do
      user.regular!
    end

    it_behaves_like "guest abilities"
    it_behaves_like "without email abilities"

    it { is_expected.to be_able_to :create, Answer }
    it { is_expected.to be_able_to :create, Attachment }
    it { is_expected.to be_able_to :create, Comment }
    it { is_expected.to be_able_to :create, identity }
    it { is_expected.not_to be_able_to :create, identity2 }
    it { is_expected.to be_able_to :create, Question }
    it { is_expected.to be_able_to :create, Tag }
    it { is_expected.to be_able_to :create, Vote }

    it { is_expected.to be_able_to :logins, user  }
    it { is_expected.not_to be_able_to :logins, user2  }

    it { is_expected.to be_able_to :vote_up, question2 }
    it { is_expected.to be_able_to :vote_up, answer2 }
    it { is_expected.to be_able_to :vote_up, comment2 }
    it { is_expected.not_to be_able_to :vote_up, question }
    it { is_expected.not_to be_able_to :vote_up, answer }
    it { is_expected.not_to be_able_to :vote_up, comment }

    it { is_expected.to be_able_to :update, question }
    it { is_expected.to be_able_to :update, answer }
    it { is_expected.to be_able_to :update, comment }
    it { is_expected.not_to be_able_to :update, question2 }
    it { is_expected.not_to be_able_to :update, answer2 }
    it { is_expected.not_to be_able_to :update, comment2 }

    it { is_expected.to be_able_to :destroy, question }
    it { is_expected.to be_able_to :destroy, answer }
    it { is_expected.to be_able_to :destroy, comment }
    it { is_expected.to be_able_to :destroy, attachment }
    it { is_expected.not_to be_able_to :destroy, question2 }
    it { is_expected.not_to be_able_to :destroy, answer2 }
    it { is_expected.not_to be_able_to :destroy, comment2 }
    it { is_expected.not_to be_able_to :destroy, attachment2 }

    it { is_expected.to be_able_to :mark_best, answer }
    it { is_expected.not_to be_able_to :mark_best, answer2 }
  end
end
