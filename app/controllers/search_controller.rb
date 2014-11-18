class SearchController < ApplicationController
  before_action :find_model

  def search
    authorize! :search, @model
    @resources = []
    @resources = @model.search(params[:q], page: params[:page], per_page: @model.try(:default_per_page) || ThinkingSphinx.count) unless params[:q].blank?
    #@questions = Question.search(params[:search][:query], page: params[:page], per_page: Question.default_per_page)
    #@questions.context.panes << ThinkingSphinx::Panes::ExcerptsPane
    @resources = @resources.group_by { |resource| resource.class.name.downcase.to_sym  } if @model == ThinkingSphinx && !params[:q].blank?
    render "#{params[:target]}_result"
  end

  private

    def find_model
      available_models = {answers: Answer, questions: Question, comments: Comment, users: User, combined: ThinkingSphinx}
      @model = available_models[params[:target].to_sym]

      redirect_to root_path unless @model
    end
end
