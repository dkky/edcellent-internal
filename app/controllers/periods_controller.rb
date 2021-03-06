class PeriodsController < ApplicationController
  protect_from_forgery except: [:duplicate, :calendar_search]
  before_action :set_period, only: [:show, :edit, :update, :destroy, :drop]
  before_action :check_access, only: [:index, :show, :edit, :update, :destroy, :calendar, :search]
  before_action :sanitize_page_params, only: [:create, :update]
  before_action :sanitize_time_params, only: [:update]
  before_action :check_google_calendar_authorization, only: [:new, :calendar, :index]

  respond_to :html, :json

  def new
    @period = Period.new
  end

  def newmodal
    @period = Period.new
    render 'newmodal.js.erb'
  end

  def search
    if current_user.admin? || current_user.superadmin?
      @periods = Period.all
    elsif current_user.tutor?
      @periods = current_user.periods
    elsif current_user.student?
      @periods = current_user.group.periods
    end

    if current_user.admin? || current_user.superadmin?
      @filterrific = initialize_filterrific(
        Period,
        params[:filterrific],
        select_options: {
          with_different_status: Period.options_for_different_status,
          with_different_group: Period.options_for_different_group_admin,
          with_different_tutor: Period.options_for_different_tutor_admin,
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
          with_different_group: Period.options_for_different_group(current_user),
          with_different_grouping: Period.options_for_tagging 
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

# change this whole thing........it's a mess
  def index
    if current_user.admin? || current_user.superadmin?
      @periods = Period.all
    elsif current_user.tutor?
      @periods = current_user.periods
    elsif current_user.student?
      @periods = current_user.attending_periods
    end
  end

  def calendar_search
    if params[:search] && current_user.admin? || params[:search] && current_user.superadmin?
      @periods = Period.calendar_search(params[:search])
      if @periods.count > 0
        @filterrific = initialize_filterrific(
          @periods,
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
          format.js { render 'calendar_search.js.erb'}        
        end
      else
        @periods = Period.all
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
          format.js { render 'calendar_search.js.erb'}
        end
      end
    elsif params[:search] && current_user.tutor?
      @periods = current_user.periods
      @filterrific = initialize_filterrific(
        @periods,
        params[:filterrific],
        select_options: {
          with_different_status: Period.options_for_different_status,
          with_different_group: Period.options_for_different_group_based_on_tutors(current_user),
          with_different_grouping: Period.options_for_tagging 
        },
      ) or return
      @periods = @filterrific.find.page(params[:page])
      respond_to do |format|
        format.html 
        format.js { render 'calendar_search.js.erb'}
      end
    else
      # for resetting the filter
      @periods = current_user.periods
      @filterrific = initialize_filterrific(
        @periods,
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
        format.js { render 'calendar_search.js.erb'}
      end
    end
  end


  def calendar
    @period = Period.new
    if current_user.admin? || current_user.superadmin?
      # if params[:search] 
        # @periods = Period.calendar_search(params[:search])
        # @periods = Period.search { fulltext params[:search] }.results
        # render 'periods/search_result'
      # @filterrific = initialize_filterrific(
      #   Period,
      #   params[:filterrific],
      #   select_options: {
      #     with_different_status: Period.options_for_different_status,
      #     with_different_group: Period.options_for_different_group_admin,
      #     with_different_grouping: Period.options_for_tagging 
      #   },
      # ) or return
      # @periods = @filterrific.find.page(params[:page])

      # render 'index.js.erb'
      # respond_to do |format|
      #   format.html 
      #   format.js { render 'index.js.erb'}
      # end
      # else
        @periods = Period.all
      # end
    elsif current_user.tutor?
      @periods = current_user.periods
    elsif current_user.student?
      @periods = current_user.attending_periods
    end
  end

  def create  
    # byebug
    @period = Period.new(periods_params)
    if current_user.tutor? || current_user.admin? || current_user.superadmin?
      @period.tutor_id = current_user.id
      @period.period_status = 1
    end
    if sanitize_group_params.count > 0
      if existing_group = Group.joins(:users).where('users.id' => sanitize_group_params).select {|g| g.user_ids.sort == sanitize_group_params.sort}.first
        @period.group_id = existing_group.id
      else
        new_group = Group.new
        new_group.user_ids = sanitize_group_params
        user = User.find(*sanitize_group_params)
        if user.class == Array
          new_group.name = User.find(*sanitize_group_params).pluck(:english_name, :last_name).map {|arr| arr.join(" ") }.join(", ")
        else 
          new_group.name = user.english_name + ' ' + user.last_name
        end
        new_group.save
        @period.group_id = new_group.id
      end
      @period.grouping_list = "1 to " + @period.group.users.count.to_s
      @period.title = @period.subject + ': ' + @period.group.name + ' - ' + @period.tutor.english_name + ' ' + @period.session_number.to_s
      if @period.save
        # byebug
    #     render 'periods/create.js.erb' 
        if current_user.id == @period.tutor.id
          GoogleCalendarJob.perform_later(action: 'create', period_id: @period.id, session: session[:authorization], client_options: client_options)
        end
        render 'create.js.erb'
        # create_event(@period.id)
        # byebug
      else
        render 'newmodal.js.erb'
      end
    else
      @period.save
      render 'newmodal.js.erb'
    end
  end

  def show
  end

  def edit
    render 'edit.js.erb'
  end

  def drop
    @period.update_attributes(periods_params)
    # update_event(@period.google_event_id)
    if current_user.id == @period.tutor.id
      GoogleCalendarJob.perform_later(action: 'update', google_event_id: @period.google_event_id, period_id: @period.id, session: session[:authorization], client_options: client_options)
    end

    if Rails.env.production? && @period.done?
      session_date = @period.start_time.strftime("%d/%-m %a")
      session_desc = @period.group.users.pluck(:english_name).join(", ") + ' ' + @period.session_number.to_s
      session_time = @period.start_time.strftime("%-I:%M%p") + " - " + @period.end_time.strftime("%-I:%M %p")
      session_tutor = @period.tutor.english_name
      session_updated_at = @period.updated_at.to_s
      zap = ENV['zapier_backup_call'] + "?date=#{session_date}&time=#{session_time}&tutor=#{session_tutor}&session=#{session_desc}&updated_at=#{session_updated_at}"
      resp = Unirest.get(zap)
    end
    render "update.js.erb"
  end

# update
  def update
    @period.update_attributes(periods_params)
    @period.grouping_list = "1 to " + @period.group.users.count.to_s
    @period.title = @period.subject + ': ' + @period.group.name + ' - ' + @period.tutor.english_name + ' ' + @period.session_number.to_s
    if sanitize_group_params.count > 0
      user = User.find(*sanitize_group_params)
      if existing_group = Group.joins(:users).where('users.id' => sanitize_group_params).select {|g| g.user_ids == sanitize_group_params}.first
        # @period.group_id = existing_group.id
      else 
        new_group = Group.new
        new_group.user_ids = sanitize_group_params
        if sanitize_group_params.count > 1
          new_group.name = user.pluck(:english_name, :last_name).map {|arr| arr.join(" ") }.join(", ")
        else 
          new_group.name = user.english_name + user.last_name
        end
        new_group.save
      end
      @period.group_id = new_group.id
    end
    @period.grouping_list = "1 to " + @period.group.users.count.to_s
    @period.title = @period.subject + ': ' + @period.group.name + ' - ' + @period.tutor.english_name + ' ' + @period.session_number.to_s
    if @period.save
      # update_event(@period.google_event_id)
      if current_user.id == @period.tutor.id
      # unless current_user.admin? || current_user.superadmin?
        GoogleCalendarJob.perform_later(action: 'update', google_event_id: @period.google_event_id, period_id: @period.id, session: session[:authorization], client_options: client_options)

        if Rails.env.production? && @period.done? 
          session_date = @period.start_time.strftime("%d/%-m %a")
          session_desc = @period.group.users.pluck(:english_name).join(", ") + ' ' + @period.session_number.to_s
          session_time = @period.start_time.strftime("%-I:%M%p") + " - " + @period.end_time.strftime("%-I:%M %p")
          session_tutor = @period.tutor.english_name
          session_updated_at = @period.updated_at.to_s
          zap = ENV['zapier_backup_call'] + "?date=#{session_date}&time=#{session_time}&tutor=#{session_tutor}&session=#{session_desc}&updated_at=#{session_updated_at}"
          resp = Unirest.get(zap)
        end
      end
    
      render "modal_update.js.erb"
    else
      render 'edit.js.erb'
    end
  end

  def destroy
    @period = Period.destroy(params[:id])
    if current_user.id == @period.tutor.id
      GoogleCalendarJob.perform_later(action: 'delete', google_event_id: @period.google_event_id, period_id: @period.id, session: session[:authorization], client_options: client_options)
    end
    # delete_event(@period.google_event_id, @period.id, params[:attribute])
    @period_id = @period.id
    if params[:attribute] == "delete_period_modal" || params[:attribute] == "delete_period_calendar"
      respond_to do |f|
        f.html { redirect_to root_path }
        f.js { render 'destroy_in_modal.js.erb', locals: { source_of_action: params[:attribute] } }
      end           
    else
      respond_to do |f|
        f.html { redirect_to root_path }
        f.js { render 'destroy.js.erb' }
      end   
    end
  end

  def duplicate
    @source = Period.find(params[:format])
    @period = @source.dup
    # if @period.save
    #   flash[:notice] = "This is a duplicate. Please update the info and save"
    #   redirect_to edit_period_path(@period)
    # else
    #   flash[:notice] = "failed to duplicate"
    #   redirect_to root_path
    # end
    flash.now[:warning] = "This is a duplicate. Please update the info and save"
    render 'newmodal.js.erb'
  end

  def change_status
    @period = Period.find(params[:id])
    if @period.incomplete?
      @period.update(period_status: 0)
    elsif @period.done?
      @period.update(period_status: 1)  
    end

    if current_user.id == @period.tutor.id
      GoogleCalendarJob.perform_later(action: 'update', google_event_id: @period.google_event_id, period_id: @period.id, session: session[:authorization], client_options: client_options)
    end
    # render "update.js.erb"
    if Rails.env.production? && @period.done?
      session_date = @period.start_time.strftime("%d/%-m %a")
      session_desc = @period.group.users.pluck(:english_name).join(", ") + ' ' + @period.session_number.to_s
      session_time = @period.start_time.strftime("%-I:%M%p") + " - " + @period.end_time.strftime("%-I:%M %p")
      session_tutor = @period.tutor.english_name
      session_updated_at = @period.updated_at.to_s
      zap = ENV['zapier_backup_call'] + "?date=#{session_date}&time=#{session_time}&tutor=#{session_tutor}&session=#{session_desc}&updated_at=#{session_updated_at}"
      resp = Unirest.get(zap)
    end
    
    render "modal_update.js.erb"

    # update_event(@period.google_event_id)
    # *****need to fix this later!
    # respond_to do |format|
    #   format.html { redirect_to periods_path }
    #   # format.js { render "change_status.js.erb" }
    #   format.js { render "update.js.erb" }
    # end
  end

  private

  def sanitize_group_params
    if !params[:groups].blank?
      params[:groups].map(&:to_i) 
    else  
      return []
    end
  end

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
    params.require(:period).permit(:start_time, :end_time, :subject, :description, :note, :tutor_id, :period_status, :session_number)
  end

  def set_period
    @period = Period.find(params[:id])
  end

  def create_event(event_id)
    byebug
    begin
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      zone = ActiveSupport::TimeZone.new("Melbourne")
      @period = Period.find(event_id)
      if @period.incomplete?
        color = 11
      else
        color = 1
      end
      event = Google::Apis::CalendarV3::Event.new({
        summary: @period.title,
        location: '180 Bourke Street',
        description: @period.description,
        color_id: color,
        start: {
          # date_time: '2017-09-30T12:30:00+10:00'
          date_time: @period.start_time.in_time_zone(zone).rfc3339
          # date_time: '2017-09-28T19:00:00',
          # time_zone: 'Australia/Melbourne',
        },
        end: {
          date_time: @period.end_time.in_time_zone(zone).rfc3339
          # date_time: '2015-09-28T21:00:00',
          # time_zone: 'Australia/Melbourne',
        },
        attendees: [
          {email: 'lpage@example.com'},
          {email: 'sbrin@example.com'},
        ],
      })
      result = service.insert_event(current_user.email, event)
      # email to be changed later...
      @period.google_event_id = result.id
      @period.save
      byebug
      render "periods/create.js.erb"
    rescue Google::Apis::AuthorizationError
      # access token expired after an hour
      response = client.refresh!
      session[:authorization] = session[:authorization].merge(response)
      retry
    end
  end

  def delete_event(event_id, period_id, source_of_action)
    # byebug
    begin
      @period_id = period_id
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      service.delete_event('primary', event_id)
      if source_of_action == "delete_period_modal" || source_of_action == "delete_period_calendar"
        respond_to do |f|
          f.html { redirect_to root_path }
          f.js { render 'destroy_in_modal.js.erb', locals: { source_of_action: source_of_action } }
        end           
      else
        respond_to do |f|
          f.html { redirect_to root_path }
          f.js { render 'destroy.js.erb' }
        end   
      end
    rescue Google::Apis::AuthorizationError
      # access token expired after an hour
      response = client.refresh!
      session[:authorization] = session[:authorization].merge(response)
      retry
    end
  end

  def update_event(event_id)
    # byebug
    begin
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      result = service.get_event('primary', event_id)
      zone = ActiveSupport::TimeZone.new("Melbourne")
      @period = Period.find_by(google_event_id: event_id)
      # update info
      if @period.incomplete?
        color = 11
      else
        color = 1
      end
      result.summary = @period.title
      result.description = @period.description
      result.color_id = color
      result.start.date_time = @period.start_time.in_time_zone(zone).rfc3339
      result.end.date_time = @period.end_time.in_time_zone(zone).rfc3339
      service.update_event('primary', event_id, result)
      render "modal_update.js.erb"
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



