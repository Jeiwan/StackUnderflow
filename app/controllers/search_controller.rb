class SearchController < ApplicationController
  skip_authorization_check

  def search
    available_models = {answers: Answer, questions: Question, comments: Comment, users: User}

    if model = available_models[params[:target].to_sym]
      @resources = model.search(params[:q], page: params[:page], per_page: model.default_per_page)
      #@questions = Question.search(params[:search][:query], page: params[:page], per_page: Question.default_per_page)
      #@questions.context.panes << ThinkingSphinx::Panes::ExcerptsPane
      render "#{params[:target]}_result"
    else
      redirect_to root_path
    end
  end
end
