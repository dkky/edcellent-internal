json.array!(@periods) do |period|
  json.extract! period, :id, :note, :description
  json.tutor period.tutor.name
  array = []
  period.group.users.each do |user|
    array << user.name
  end
  if period.period_status == "done"
    json.color "blue"
    json.icon '<i class="fa fa-window-close fa-lg" style="color:black; float:left;"></i>'
  else
    json.color "red"
    json.icon '<i class="fa fa-check fa-lg" style="color:black; float:left;"></i>'
  end
  json.student array.join(", ")
  json.start period.start_time
  json.end period.end_time
  # json.url period_url(period, format: :html)
  json.update_url period_path(period, method: :patch)
  json.edit_url edit_period_path(period)
  json.destroy_url period_path(period, attribute: 'delete_period_calendar')
end