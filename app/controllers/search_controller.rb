class SearchController < ApplicationController
  skip_authorization_check

  def search
    @questions = Question.search(conditions: {title: params[:q]}, page: params[:page], per_page: Question.default_per_page)
    #@questions = Question.search(params[:search][:query], page: params[:page], per_page: Question.default_per_page)
    #@questions.context.panes << ThinkingSphinx::Panes::ExcerptsPane
    render 'questions_result'
  end
end
