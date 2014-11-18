require 'rails_helper'

RSpec.describe SearchController, :type => :controller do
  let!(:question) { create(:question, title: "test test test test")  }

  describe "GET #search" do
    let(:get_search) do
      get :search, q: "test", target: "questions" 
    end


    context "when parameters are correct" do
      it "assigns resources variable" do
        allow(Question).to receive(:search).with("test", page: nil, per_page: 10).and_return([question])
        get_search
        expect(assigns(:resources)).to eq [question]
      end
      
      it "renders results page" do
        get_search
        expect(response).to render_template "questions_result"
      end
    end

    context "when parameters are incorrect" do
      context "when query is empty" do
        let(:get_search) do
          get :search, q: "", target: "questions" 
        end

        it "assigns empty resources variable" do
          allow(Question).to receive(:search).with("", page: nil, per_page: 10).and_return([])
          get_search
          expect(assigns(:resources)).to be_empty
        end

        it "renders results page" do
          get_search
          expect(response).to render_template "questions_result"
        end
      end
      context "when target is empty" do
        let(:get_search) do
          get :search, q: "test", target: "" 
        end

        before { get_search }

        it "doesn't assign resources variable" do
          expect(assigns(:resources)).to be_nil
        end

        it "redirects to index" do
          expect(response).to redirect_to root_path
        end
      end

      context "when target is invalid" do
        let(:get_search) do
          get :search, q: "test", target: "some_other_model_we_dont_have_in_the_project" 
        end

        before { get_search }

        it "doesn't assign resources variable" do
          expect(assigns(:resources)).to be_nil
        end

        it "redirects to index" do
          expect(response).to redirect_to root_path
        end
      end
    end
  end
end
