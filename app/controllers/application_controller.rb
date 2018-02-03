class ApplicationController < ActionController::Base
  include Clearance::Controller
  protect_from_forgery with: :exception
  include ActionController::MimeResponds

  def check_google_calendar_authorization
    unless session[:authorization]
      redirect_to redirect_path
    end
  end

  def check_admin_access
    redirect_to root_path unless current_user && current_user.admin?
  end
end
