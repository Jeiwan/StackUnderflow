require 'rails_helper'

RSpec.describe TagsController, :type => :controller do
  let(:tags) { create_list(:tag, 3) }
  let!(:question1) { create(:question, tag_list: tags[0].name) }
  let!(:question2) { create(:question, tag_list: tags[1].name) }
  let!(:question3) { create(:question, tag_list: tags[1].name) }
  let!(:question4) { create(:question, tag_list: tags[2].name) }

  describe "GET #index" do
    before { get :index }

    it "returns a list of all tags sorted by popularity" do
      expect(assigns(:tags)).to match_array [tags[0], tags[2], tags[1]]
    end

    it "renders index template" do
      expect(response).to render_template :index
    end
  end

  describe "GET #alphabetical" do
    before { get :alphabetical }

    it "returns a list of all tags sorted alphabetically" do
      expect(assigns(:tags)).to match_array tags.reverse
    end

    it "renders index template" do
      expect(response).to render_template :index
    end
  end

  describe "GET #newest" do
    before { get :newest}

    it "returns a list of all tags sorted by the date of creation" do
      expect(assigns(:tags)).to match_array tags
    end

    it "renders index template" do
      expect(response).to render_template :index
    end
  end
end
