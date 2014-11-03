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

  check_authorization
  skip_authorization_check if: :devise_controller?
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render json: :nothing, status: 401 }
      format.js { render json: :nothing, status: 401 }
    end
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
          flash[:danger] = "Unable to update #{resource.class.name}. See errors below."
          format.json { render json: resource.errors, status: 422 }
          format.html { render "edit" }
        else
          flash[:success] = "#{resource.class.name} was successfully updated."
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
      if user_signed_in? && current_user.status == "without_email"
        flash.now[:danger] = "Your account is restricted. Please, provide your email address on 'Edit profile' page."
      end
      if user_signed_in? && current_user.status == "pending"
        flash.now[:info] = "We sent a confirmation email on #{current_user.unconfirmed_email}. Please, click 'Confirm my account' link in the email or provide other address below."
      end
    end
end
