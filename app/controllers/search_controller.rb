class SearchController < ApplicationController
  before_action :find_model
  before_action :choose_sorting
  before_action :set_per_page

  def search
    authorize! :search, @model
    @resources = []
    @resources = @model.search(params[:q], order: @sorting, page: params[:page], per_page: @per_page) unless params[:q].blank?
    #@questions = Question.search(params[:search][:query], page: params[:page], per_page: Question.default_per_page)
    #@questions.context.panes << ThinkingSphinx::Panes::ExcerptsPane
    #@resources.reverse! if @sorting
    @resources = @resources.group_by { |resource| resource.class.name.downcase.to_sym  } if @model == ThinkingSphinx && !params[:q].blank?
    render "#{params[:target]}_result"
  end

  private

    def find_model
      available_models = {answers: Answer, questions: Question, comments: Comment, users: User, combined: ThinkingSphinx}
      @model = available_models[params[:target].to_sym]

      redirect_to root_path unless @model
    end

    def choose_sorting
      available_sortings = {
        answers: {
          date: 'id DESC',
          popularity: 'votes_sum DESC',
          author: 'author ASC'
        },
        comments: {
          date: 'id DESC',
          popularity: 'votes_sum DESC',
          author: 'author ASC',
        },
        questions: {
          title: 'title ASC',
          author: 'author ASC',
          date: 'id DESC',
          activity: 'updated_at DESC',
          popularity: 'votes_sum DESC'
        },
        users: {
          alphabetically: 'username ASC',
          location: 'location ASC',
          full_name: 'full_name ASC',
          date: 'id DESC',
          reputation: 'reputation_sum DESC'
        }
      }
      #available_sortings = {date: 'id DESC', activity: 'updated_at DESC', popularity: 'votes_sum DESC', reputation: 'reputation_sum DESC', alphabetically: 'username ASC', location: 'location ASC', author: 'author ASC', title: 'title ASC', full_name: 'full_name ASC'}
      @sorting = (params[:order].blank? || params[:target].blank?) ? nil : available_sortings[params[:target].to_sym][params[:order].to_sym]
    end

    def set_per_page
     @per_page = @model.try(:default_per_page) || ThinkingSphinx.count
    end
end
