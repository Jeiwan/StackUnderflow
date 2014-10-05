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
    it { is_expected.to accept_nested_attributes_for :attachments }
  end

  describe "instance methods" do
    describe "#mark_best!" do
      let(:question) { create(:question, tag_list: "test,west,east") }
      let!(:answer) { create(:answer, question: question) }

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
  end

end
