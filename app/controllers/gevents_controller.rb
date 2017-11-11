class GeventsController < ApplicationController
  def redirect
    client = Signet::OAuth2::Client.new(client_options)
    status = client.update!(
      additional_parameters: {
        access_type: 'offline',
        prompt: 'consent'
      }
    )    
    redirect_to client.authorization_uri.to_s
  end

  def callback
    if params[:error]
      redirect_to root_path
    else 
      client = Signet::OAuth2::Client.new(client_options)
      client.code = params[:code]
      response = client.fetch_access_token!
      session[:authorization] = response
      current_user.update(google_event: 1)
      redirect_to root_path
    end
  end

  # def calendars
  #   byebug
  #   client = Signet::OAuth2::Client.new(client_options)
  #   client.update!(session[:authorization])

  #   service = Google::Apis::CalendarV3::CalendarService.new
  #   service.authorization = client

  #   @calendar_list = service.list_calendar_lists
  #   render 'periods/calendar'
  # end

  # def events
  #   byebug
  #   client = Signet::OAuth2::Client.new(client_options)
  #   client.update!(session[:authorization])

  #   service = Google::Apis::CalendarV3::CalendarService.new
  #   service.authorization = client

  #   @event_list = service.list_events(params[:calendar_id])
  # end

  def create
    begin
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(session[:authorization])
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      zone = ActiveSupport::TimeZone.new("Melbourne")
      period = Period.find(params[:details])
      event = Google::Apis::CalendarV3::Event.new({
        summary: period.title,
        location: '180 Bourke Street',
        description: period.description,
        start: {
          # date_time: '2017-09-30T12:30:00+10:00'
          date_time: period.start_time.in_time_zone(zone).rfc3339
          # date_time: '2017-09-28T19:00:00',
          # time_zone: 'Australia/Melbourne',
        },
        end: {
          date_time: period.end_time.in_time_zone(zone).rfc3339
          # date_time: '2015-09-28T21:00:00',
          # time_zone: 'Australia/Melbourne',
        },
        attendees: [
          {email: 'lpage@example.com'},
          {email: 'sbrin@example.com'},
        ],
      })
      result = service.insert_event(params[:calendar_id], event)
      period.google_event_id = result.id
      period.save
      redirect_to period     
    rescue Google::Apis::AuthorizationError
      # access token expired after an hour
      response = client.refresh!
      session[:authorization] = session[:authorization].merge(response)
      retry
    end
  end

  private

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
