class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
  protect_from_forgery with: :exception
  ## before_action :authenticate_user!
  def require_sign_in
      unless current_user
          flash[:alert] = "You must be logged in to do that"

          redirect_to new_user_session_path
      end
  end

  def authorize_user
      wiki = Wiki.find(params[:id])
      unless current_user == wiki.creator || current_user.admin?
          flash[:alert] = "You must be an admin to do that."
          redirect_to wikis_path
      end
  end
end
