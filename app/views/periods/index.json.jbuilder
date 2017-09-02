json.array!(@periods) do |period|
  json.extract! period, :id, :note, :description
  json.tutor period.user.name
  array = []
  period.group.users.each do |user|
    array << user.name
  end
  json.student array.join(", ")
  json.start period.start_time
  json.end period.end_time
  json.url period_url(period, format: :html)
end