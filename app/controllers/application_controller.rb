class ApplicationController < ActionController::API
  include Devise::Controllers::Helpers
  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found

  def render_unprocessable_entity(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_record_not_found
    render json: { error: ["Not Found"] }, status: :not_found
  end

  def authenticate_user!
    super
    Rails.logger.debug("Authenticated User (after super): #{current_user.inspect}")
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name password password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name password password_confirmation])
  end
end
