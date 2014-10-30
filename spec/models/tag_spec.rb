require 'rails_helper'

RSpec.describe Tag, :type => :model do

  describe "associations" do
    it { is_expected.to have_and_belong_to_many :questions }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :name  }
    it { is_expected.to ensure_length_of(:name).is_at_least(1).is_at_most(24)  }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive  }
  end

  describe "scopes" do
    let(:tags) { create_list(:tag, 3) }
    let!(:question1) { create(:question, tag_list: tags[0].name) }
    let!(:question2) { create(:question, tag_list: tags[1].name) }
    let!(:question3) { create(:question, tag_list: tags[1].name) }
    let!(:question4) { create(:question, tag_list: tags[2].name) }

    describe "popular" do
      it "returns a list of tags sorted by number of questions" do
        expect(Tag.popular).to match_array [tags[1], tags[2], tags[0]]
      end
    end

    describe "alphabetical" do
      it "returns a list of tags in alphabetical order" do
        expect(Tag.popular).to match_array [tags[0], tags[1], tags[2]]
      end
    end
  end

end
