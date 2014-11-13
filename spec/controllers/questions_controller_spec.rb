require 'rails_helper'

RSpec.describe QuestionsController, :type => :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:question2) { create(:question, user: user2) }

  user_sign_in

  describe "GET #index" do
    let(:questions) { create_list(:question, 2) }
    before { get :index }

    it "returns a list of questions" do
      expect(assigns(:questions)).to match_array(questions)
    end

    it "renders index view" do
      expect(response).to render_template :index
    end
  end

  describe "GET #new" do
    before { get :new }

    context "when not signed in" do
      it "redirects to sign in page" do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when signed in", sign_in: true do
      it "returns a new empty question" do
        expect(assigns(:question)).to be_a_new(Question)
      end

      it "renders new view" do
        expect(response).to render_template :new
      end
    end
  end

  describe "GET #show" do
    let(:impression) { build(:impression, question: question) }
    let(:get_show) do
      get :show, id: question.id
    end

    before do
      request.env["REMOTE_ADDR"] = impression.remote_ip
      request.env["HTTP_USER_AGENT"] = impression.user_agent
    end

    context "when visited for the first time" do
      it "creates a new impression" do
        expect{get_show}.to change(Impression, :count).by(1)
      end
    end

    context "when visited for the second time" do
      before do
        impression.save
      end

      it "doesn't create an impression" do
        expect{get_show}.not_to change(Impression, :count)
      end
    end

    it "returns a question" do
      get_show
      expect(assigns(:question)).to eq question
    end

    it "renders show view" do
      get_show
      expect(response).to render_template :show
    end
  end

  describe "POST #create" do
    let(:attributes) { attributes_for(:question) }
    let(:post_create) do
      post :create, question: attributes
    end

    context "when signed in", sign_in: true do
      context "with valid data" do
        context "with a new tag" do
          it "increases number of tags" do
            expect{post_create}.to change(Tag, :count).by(5)
          end

          it "increases total number of questions" do
            expect{post_create}.to change(Question, :count).by(1)
          end

          it "increases current user's number of questions" do
            expect{post_create}.to change(Question, :count).by(1)
          end

          it "redirects to the new question page" do
            post_create
            expect(response).to redirect_to(assigns(:question))
          end
        end

        context "with existing tags" do
          let!(:tag) { create(:tag) }
          let(:attributes) { attributes_for(:question, tag_list: "#{tag.name},windows,c++,macosx") }

          it "increases number of tags" do
            expect{post_create}.to change(Tag, :count).by(3)
          end

          it "increases total number of questions" do
            expect{post_create}.to change(Question, :count).by(1)
          end

          it "increases current user's number of questions" do
            expect{post_create}.to change(Question, :count).by(1)
          end

          it "redirects to the new question page" do
            post_create
            expect(response).to redirect_to(assigns(:question))
          end
        end

      end

      context "with invalid data" do
        let(:attributes) { attributes_for(:question, title: nil, body: nil) }

        it "doesn't increase total questions count" do
          expect{post_create}.not_to change(Question, :count)
        end

        it "doesn't increase current user's questions count" do
          expect{post_create}.not_to change(Question, :count)
        end

        it "renders new view" do
          post_create
          expect(response).to render_template :new
        end
      end
    end

    context "when not signed in" do
      before { post_create }
      it "redirects to the sign in page" do
        expect(response).to redirect_to new_user_session_path
      end
    end

  end

  describe "PUT #update" do
    let(:put_update) do
      put :update, id: question.id, question: { title: question.title.reverse, body: question.body, tag_list: question.tag_list }, format: :json
    end

    context "when signed in", sign_in: true do
      context "when question belongs to current user" do
        context "with valid data" do
          before { put_update }

          it "changes question's attribute" do
            expect(question.title).to eq question.reload.title.reverse
          end

          it "returns question's json" do
            json = JSON.parse(response.body)
            expect(json["title"]).to eq question.title.reverse
            expect(json["body"]).to eq question.body
            expect(json["list_of_tags"]).to eq question.tag_list
          end

          it "returns 200 status code" do
            expect(response.status).to eq 200
          end
        end

        context "with invalid data" do
          before do 
            put :update, id: question.id, question: { title: "", body: question.body, tag_list: question.tag_list }, format: :json
          end

          it "doesn't change question's attribute" do
            expect(question.reload.title).not_to eq question.title.reverse
          end

          it "returns 422 status" do
            expect(response.status).to eq 422
          end
        end
      end

      context "when question doesn't belong to current user" do
        let(:question) { question2 }
        before { put_update }

        it "returns 401 status code" do
          expect(response.status).to eq 401
        end
      end
    end

    context "when not signed in" do
      before { put_update }

      it "doesn't change question's attribute" do
        expect(question.reload.title).not_to eq question.title.reverse
      end

      it "returns 401 error" do
        expect(response.status).to eq 401
      end
    end

  end

  describe "DELETE #destroy" do
    let!(:answer) { create(:answer, question: question) }
    let!(:comment) { create(:question_comment, commentable: question) }
    let!(:vote) { create(:vote, votable: question, user: user2) }
    let(:delete_destroy) do
      delete :destroy, id: question
    end

    before { question }

    context "when signed in", sign_in: true do
      context "when question belongs to current user" do
        it "removes a question" do
          expect{delete_destroy}.to change(Question, :count).by(-1)
        end

        it "removes answers for the question" do
          expect{delete_destroy}.to change(Answer, :count).by(-1)
        end

        it "removes comments to the question" do
          expect{delete_destroy}.to change(Comment, :count).by(-1)
        end

        it "removes relating votes" do
          expect{delete_destroy}.to change(Vote, :count).by(-1)
        end

        it "redirects to questions path" do
          delete_destroy
          expect(response).to redirect_to questions_path
        end
      end
      
      context "when question doesn't belong to current user" do
        let(:question) { question2 }
        before { delete_destroy }

        it "redirects to root path" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when not signed in" do
      it "doesn't delete a question" do
        expect{delete_destroy}.not_to change(Question, :count)
      end

      it "redirects to sign in path" do
        delete_destroy
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "POST #add_favorite" do
    let(:post_add_favorite) do
      post :add_favorite, question_id: question.id, format: :json
    end

    context "when signed in", sign_in: true do
      it "adds question to user's favorite list" do
        expect{post_add_favorite}.to change{user.favorites.count}.by(1)
      end

      it "renders json with status" do
        post_add_favorite
        expect(response.status).to eq 200

        json = JSON.parse(response.body)
        expect(json["status"]).to eq "success"
        expect(json["count"]).to eq 1
      end
    end

    context "when not signed in" do
      it "doesn't add question to user's favorite list" do
        expect{post_add_favorite}.not_to change{user.favorites.count}
      end

      it "returns 401 status" do
        post_add_favorite
        expect(response.status).to eq 401
      end
    end
  end

  describe "POST #remove_favorite" do
    let(:post_remove_favorite) do
      post :remove_favorite, question_id: question.id, format: :json
    end

    before do
      user.add_favorite(question.id)
    end

    context "when signed in", sign_in: true do
      it "removes question from user's favorite list" do
        expect{post_remove_favorite}.to change{user.favorites.count}.by(-1)
      end

      it "renders json with status" do
        post_remove_favorite
        expect(response.status).to eq 200

        json = JSON.parse(response.body)
        expect(json["status"]).to eq "success"
        expect(json["count"]).to eq 0
      end
    end

    context "when not signed in" do
      it "doesn't remove question from user's favorite list" do
        expect{post_remove_favorite}.not_to change{user.favorite_questions.count}
      end

      it "returns 401 status" do
        post_remove_favorite
        expect(response.status).to eq 401
      end
    end
  end
end
