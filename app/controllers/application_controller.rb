require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_if_confirmed

  def default_serializer_options
    { root: false }
  end

  private
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :username
    end

    def find_parent
      resource, id = request.path.split("/")[1, 2]
      @parent = resource.singularize.classify.constantize.find(id)
    end

    def update_resource(resource)
      respond_with resource.update(send(:"#{resource.class.to_s.downcase}_params")) do |format|
        if resource.errors.any?
          format.json { render json: resource.errors, status: 422 }
          format.html { render "edit" }
        else
          format.json { render json: resource, status: 200 }
          format.html { redirect_to resource }
        end
      end
    end

    def add_user_id_to_attachments
      model = params[:controller].singularize.to_sym
      if params[model][:attachments_attributes]
        params[model][:attachments_attributes].each do |k, v|
          v[:user_id] = current_user.id
        end
      end
    end

    def check_if_confirmed
      if user_signed_in? && (current_user.confirmation_sent_at.nil? || !current_user.unconfirmed_email.nil?) && !(params[:controller] == 'users' && (params[:action] == 'update' || params[:action] == 'update_email')) && !(params[:controller] == 'devise/confirmations' && params[:action] == 'show') && !(params[:controller] == 'devise/sessions' && params[:action] == 'destroy')
        if current_user.confirmation_sent_at && current_user.confirmation_sent_at > current_user.confirmed_at
          flash.now[:success] = "We sent a confirmation email on #{current_user.unconfirmed_email}. Please, click 'Confirm my account' link in the email or provide other address below."
        else
          flash.now[:info] = "Please, provide your email address below. We will send you a confirmation email on it."
        end
        render "users/provide_email"
      end
    end
end
