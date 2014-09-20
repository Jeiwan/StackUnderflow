require 'rails_helper'

RSpec.describe Answer, :type => :model do

  describe "validations" do
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to ensure_length_of(:body).is_at_least(10).is_at_most(5000) }
  end

  describe "associations" do
    it { is_expected.to belong_to :question }
    it { is_expected.to belong_to :user }
  end

  describe "instance methods" do
    describe "#mark_best!" do
      it "marks answer as best" do
        answer = build(:answer)
        answer.mark_best!
        expect(answer).to be_best
      end
    end
  end

end
