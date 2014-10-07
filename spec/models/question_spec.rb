require 'rails_helper'

RSpec.describe Question, :type => :model do

  describe "validations" do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to ensure_length_of(:title).is_at_least(5).is_at_most(512) }
    it { is_expected.to ensure_length_of(:body).is_at_least(10).is_at_most(5000) }
    it { is_expected.to validate_presence_of :tag_list }
    it { is_expected.to allow_value("tag1,tag2,tag3,c++,c#,andoird-4.0,c--,some_tag", "sole_tag").for(:tag_list) }
    it { is_expected.not_to allow_value("tag1,###", "tag1,123a", "tag1,+++", "123tag,tag2", "##woot##", "tag@tag").for(:tag_list) }
  end

  describe "associations" do
    it { is_expected.to have_many :answers }
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :comments }
    it { is_expected.to have_and_belong_to_many :tags }
    it { is_expected.to have_many :attachments }
    it { is_expected.to accept_nested_attributes_for :attachments }
  end

  describe "methods" do
    let(:tags) { create_list(:tag, 1) }
    let(:question) { create(:question, tag_list: tags.map(&:name).join(",")) }
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

    describe "#form_tag_list" do
      it "returns question's tags separated by comma" do
        expect(question.form_tag_list).to eq tags.map(&:name).join(",")
      end
    end
  end

  describe "before_save" do
    let(:question) { build(:question, title: "Some good title", body: "Some good body", tag_list: "test,west,east") }

    context "when question has no tags" do
      it "creates tags" do
        expect{question.save}.to change(Tag, :count).by(3)
      end

      it "increases question's tags number" do
        expect{question.save}.to change(question.tags, :count).by(3)
      end

      it "sets question's tags" do
        question.save
        expect(question.tags.map(&:name).join(",")).to match "test,west,east"
      end
    end

    context "when question already has tags" do
      before do
        question.save
        question.tag_list = "best,west"
      end
      it "creates tags" do
        expect{question.save}.to change(Tag, :count).by(1)
      end

      it "changes question's tags number" do
        expect{question.save}.to change(question.tags, :count).by(-1)
      end

      it "sets question's tags" do
        question.save
        expect(question.tags.map(&:name).join(",")).to match "best,west"
      end
    end
  end
end
