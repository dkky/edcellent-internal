class Admin::PeriodsController < ApplicationController
  before_action :check_admin_access
  layout :determine_layout, only: [:index]

  def index
    if (params[:search] && current_user.admin? || params[:search] && current_user.superadmin?) 
      @periods = Period.calendar_search(params[:search])
      if @periods.count > 0
        @filterrific = initialize_filterrific(
          @periods,
          params[:filterrific],
          select_options: {
            with_different_status: Period.options_for_different_status,
            with_different_group: Period.options_for_different_group_admin,
            with_different_tutor: Period.options_for_different_tutor_admin,
            with_different_grouping: Period.options_for_tagging,
            sorted_by: Period.options_for_sorted_by
          },
        ) or return
        @periods = @filterrific.find.page(params[:page])

        respond_to do |format|
          format.html 
          format.js { render 'index.js.erb'}        
        end
      else
        @periods = Period.all
        @filterrific = initialize_filterrific(
          Period,
          params[:filterrific],
          select_options: {
            with_different_status: Period.options_for_different_status,
            with_different_group: Period.options_for_different_group_admin,
            with_different_tutor: Period.options_for_different_tutor_admin,
            with_different_grouping: Period.options_for_tagging,
            sorted_by: Period.options_for_sorted_by
          },
        ) or return
        @periods = @filterrific.find.page(params[:page])
        respond_to do |format|
          format.html 
          format.js { render 'index.js.erb'}
        end
      end
    else
      @periods = Period.all
      @filterrific = initialize_filterrific(
        Period,
        params[:filterrific],
        select_options: {
          with_different_status: Period.options_for_different_status,
          with_different_group: Period.options_for_different_group_admin,
          with_different_tutor: Period.options_for_different_tutor_admin,
          with_different_grouping: Period.options_for_tagging,
          sorted_by: Period.options_for_sorted_by
        },
      ) or return
      @periods = @filterrific.find.page(params[:page])
      respond_to do |format|
        format.html 
        format.js { render 'calendar_search.js.erb'}
      end
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
    delete_event(@period.google_event_id, @period.id)
  end

  private

  def check_access
    redirect_to '/sign_in' unless current_user
  end

  def delete_event(event_id, period_id)
    begin
      @period_id = period_id
      @periods = Period.all
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
    current_user.admin? || current_user.superadmin? ? "admin" : "application"
  end
end
