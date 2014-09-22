class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  private
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :username
    end

    def get_variables_for_question_show
      @answers = @question.answers.order('best DESC, created_at')
      @comments = @question.comments.order('created_at DESC')
      @comment = Comment.new
    end
end
