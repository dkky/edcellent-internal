json.extract! period, :id, :note, :description
json.tutor period.tutor.name
array = []
period.group.users.each do |user|
  array << user.name
end
json.student array.join(", ")
json.start period.start_time
json.end period.end_time
if period.period_status == "done"
  json.color "blue"
else
  json.color "red"
end
json.update_url period_path(period, method: :patch)
json.edit_url edit_period_path(period)
json.destroy_url period_path(period, attribute: 'delete_period_calendar')

