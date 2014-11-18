class SearchController < ApplicationController
  skip_authorization_check

  def search
    available_models = {answers: Answer, questions: Question, comments: Comment, users: User, combined: ThinkingSphinx}

    if model = available_models[params[:target].to_sym]
      @resources = model.search(params[:q], page: params[:page], per_page: model.try(:default_per_page) || ThinkingSphinx.count)
      #@questions = Question.search(params[:search][:query], page: params[:page], per_page: Question.default_per_page)
      #@questions.context.panes << ThinkingSphinx::Panes::ExcerptsPane
      @resources = @resources.group_by { |resource| resource.class.name.downcase.to_sym  } if model == ThinkingSphinx
      render "#{params[:target]}_result"
    else
      redirect_to root_path
    end
  end
end
