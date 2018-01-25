class ApplicationController < ActionController::Base
  include Clearance::Controller
  protect_from_forgery with: :exception
  include ActionController::MimeResponds

  def check_google_calendar_authorization
    unless session[:authorization]
      redirect_to redirect_path
    end
  end
end
