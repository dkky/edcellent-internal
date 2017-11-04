class PeriodsController < ApplicationController
  before_action :set_period, only: [:show, :edit, :update, :destroy]
  before_action :check_access, only: [:index, :show, :edit, :update, :destroy, :calendar, :search]
  before_action :sanitize_page_params, only: [:create, :update]
  before_action :sanitize_time_params, only: [:update]

  respond_to :html, :json

  def new
    @period = Period.new
  end

  def search
    if current_user.admin?
      @periods = Period.all
    elsif current_user.tutor?
      @periods = current_user.periods
    elsif current_user.student?
      @periods = current_user.group.periods
    end

    if current_user.admin?
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
    else
      @filterrific = initialize_filterrific(
        Period.where(tutor_id: current_user.id),
        params[:filterrific],
        select_options: {
          with_different_status: Period.options_for_different_status,
          with_different_group: Period.options_for_different_group(current_user)
        },
        default_filter_params: {

        },
      ) or return
      @periods = @filterrific.find.page(params[:page])
    end

    respond_to do |format|
      format.html 
      format.js 
    end
  end

  def index
    if current_user.admin?
      @periods = Period.all
    elsif current_user.tutor?
      @periods = current_user.periods
    elsif current_user.student?
      @periods = current_user.group.periods
    end
  end

  def calendar
    if current_user.admin?
      @periods = Period.all
    elsif current_user.tutor?
      @periods = current_user.periods
    elsif current_user.student?
      @periods = current_user.group.periods
    end
  end

  def create
    byebug
    @period = Period.new(periods_params)
    if params[:groups].length > 1
      random_group = Group.new(group_status: 1)
      random_group.name = User.find(*params[:groups].map(&:to_i)).pluck(:first_name, :last_name).map {|arr| arr.join(" ") }.join(", ") + " (Temporary) & random number"
      random_group.save
      @period.group_id = random_group.id
    else
      @period.group_id = params[:groups][0].to_i
    end
    @period.grouping_list = "1 to " + @period.group.users.count.to_s
    @period.title = @period.subject + ': ' + @period.group.users.pluck(:first_name, :last_name).map {|arr| arr.join(" ") }.join(", ") + ' - ' + @period.tutor.first_name
    if @period.save
      redirect_to new_event_url(calendar_id: "noone.knowu@gmail.com", details: @period.id)
      # pass the period id so that can pass the details to be saved in google calendar
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    @period.update_attributes(periods_params)
    if !params[:group].blank?
      if params[:groups].length > 1
        random_group = Group.new(group_status: 1)
        random_group.name = User.find(*params[:groups].map(&:to_i)).pluck(:first_name, :last_name).map {|arr| arr.join(" ") }.join(", ") + " (Temporary) & random number"
        random_group.save
        @period.group_id = random_group.id
      else
        @period.group_id = params[:groups][0].to_i
      end
    end
    if @period.save
      update_event(@period.google_event_id)
    else
      redirect_to @period
    end
  end

  def destroy
    @period = Period.destroy(params[:id])
    delete_event(@period.google_event_id)
  end

  def duplicate
    @source = Period.find(params[:format])
    @period = @source.dup
    flash.now[:notice] = "This is a duplicate. Please update the info and save"
    render 'new'
  end

  def change_status
    @period = Period.find(params[:id])
    if @period.incomplete?
      @period.update(period_status: 0)
    elsif @period.done?
      @period.update(period_status: 1)  
    end
    respond_to do |format|
      format.html { redirect_to periods_path }
      format.js { render "change_status.js.erb" }
    end
  end

  private

  def sanitize_page_params
    if !params[:period][:period_status].blank?
      params[:period][:period_status] = params[:period][:period_status].to_i
    end
  end

  def sanitize_time_params
    params[:period][:start_time] = params[:period][:start_time].to_datetime.strftime '%Y-%m-%d %H:%M:%S'
    params[:period][:end_time] = params[:period][:end_time].to_datetime.strftime '%Y-%m-%d %H:%M:%S'
  end

  def periods_params
    params.require(:period).permit(:start_time, :end_time, :subject, :description, :note, :tutor_id, :period_status)
  end

  def check_access
    redirect_to '/sign_in' unless current_user
  end

  def set_period
    @period = Period.find(params[:id])
  end

  def delete_event(event_id)
    begin
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      service.delete_event('primary', event_id)
      respond_to do |f|
        f.html { redirect_to root_path }
        f.js 
      end   
    rescue Google::Apis::AuthorizationError
      # access token expired after an hour
      response = client.refresh!
      session[:authorization] = session[:authorization].merge(response)
      retry
    end
  end

  def update_event(event_id)
    begin
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      result = service.get_event('primary', event_id)
      zone = ActiveSupport::TimeZone.new("Melbourne")
      period = Period.find_by(google_event_id: event_id)
      # update info
      byebug
      result.summary = period.title
      result.description = period.description
      result.start.date_time = period.start_time.in_time_zone(zone).rfc3339
      result.end.date_time = period.end_time.in_time_zone(zone).rfc3339
      # byebug
      service.update_event('primary', event_id, result)
      respond_to do |f|
        f.html { redirect_to period }
        f.js { render 'calendar.html.erb' }
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
end
