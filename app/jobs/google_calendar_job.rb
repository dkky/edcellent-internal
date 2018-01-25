class GoogleCalendarJob < ApplicationJob
  queue_as :default

  def perform(args = {})
    if args[:action] == 'create'
      create_event(args[:period_id], args[:session], args[:client_options])
    elsif args[:action] == 'update'
      update_event(args[:google_event_id], args[:session], args[:client_options], args[:period_id])
    elsif args[:action] == 'delete'
      delete_event(args[:period_id], args[:session], args[:client_options], args[:google_event_id])
    end
  end

  private

  def delete_event(period_id, session, client_options, event_id)
    begin
      @period_id = period_id
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(session)
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      service.delete_event('primary', event_id)
    rescue Google::Apis::AuthorizationError
      # access token expired after an hour
      response = client.refresh!
      session = session.merge(response)
      retry
    end
    puts 'Destroyed'
  end

  def update_event(event_id, session, client_options, period_id)
    byebug
    begin
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(session)
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
    rescue Google::Apis::AuthorizationError
      # access token expired after an hour
      response = client.refresh!
      session = session.merge(response)
      retry
    end
  end

  def create_event(event_id, session, client_options)
    begin
      client = Signet::OAuth2::Client.new(client_options)
      client.update!(session)
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
      result = service.insert_event('noone.knowu@gmail.com', event)
      ### email to be changed later...(@period.tutor.email)
      @period.google_event_id = result.id
      @period.save
    rescue Google::Apis::AuthorizationError
      # access token expired after an hour
      response = client.refresh!
      session = session.merge(response)
      retry
    end
    puts 'Created'
  end


end
