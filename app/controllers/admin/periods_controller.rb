class Admin::PeriodsController < ApplicationController
  before_action :check_access, only: [:index, :change_status]
  layout :determine_layout, only: [:index]

  def index
    if current_user.admin?
      @periods = Period.all
    elsif current_user.tutor?
      @periods = current_user.periods
    elsif current_user.student?
      @periods = current_user.group.periods
    end

    @filterrific = initialize_filterrific(
        Period,
        params[:filterrific],
        select_options: {
          with_different_status: Period.options_for_different_status,
          with_different_group: Period.options_for_different_group_admin,
          with_different_grouping: Period.options_for_tagging 
        },
      ) or return
      @periods = @filterrific.find.page(params[:page])

      
    respond_to do |format|
      format.html 
      format.js 
    end
  end

  def change_status
    @period = Period.find(params[:id])
    if @period.incomplete?
      @period.update(period_status: 0)
    elsif @period.done?
      @period.update(period_status: 1)  
    end
    respond_to do |format|
      format.html { redirect_to admin_periods }
      format.js { render "change_status.js.erb" }
    end
  end

  def destroy
    @period = Period.destroy(params[:id])
    delete_event(@period.google_event_id)
  end

  private

  def check_access
    redirect_to '/sign_in' unless current_user
  end

  def delete_event(event_id)
    begin
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      service.delete_event('primary', event_id)
      respond_to do |f|
        f.html { redirect_to admin_periods }
        f.js
      end
    rescue Google::Apis::AuthorizationError
      # access token expired after an hour
      response = client.refresh!
      session[:authorization] = session[:authorization].merge(response)
      retry
    end
  end

  def client_options
    {
      client_id: ENV['google_client_id'],
      client_secret: ENV['google_client_secret'],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: callback_url
    }
  end

  def determine_layout
    current_user.admin? ? "admin" : "application"
  end
end
