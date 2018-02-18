require 'csv'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# #create groups
# group1 = Group.create(name: 'James, Arthur & Kim', group_status: 0)
# group2 = Group.create(name: 'Tim Li', group_status: 0)
# group3 = Group.create(name: 'James Li', group_status: 0)
# # random_group1 = Group.create(name: 'Tim & Kenny (Temporary 1)', group_status: 1)
# puts "#{Group.all.count} groups have been created."
# #create students
# student1 = group2.users.create(first_name: 'Tim', last_name: 'Li', email: 'tim@edcellent.com',password: '12345678',user_access: 1, school: 'Wesley', year_level: 'Year 11', wechat_account: 'hehe1', phone_number: '0417313112')
# student2 = group3.users.create(first_name: 'Kenny', last_name: 'Li', email: 'kenny@edcellent.com',password: '12345678', user_access: 1, school: 'Wesley', year_level: 'Year 12', wechat_account: 'hehe2', phone_number: '0417313113')
# student3 = group1.users.create(first_name: 'James',last_name: 'Li',email: 'james@edcellent.com',password: '12345678', user_access: 1, school: 'Wesley', year_level: 'Year 10', wechat_account: 'hehe3', phone_number: '0417313114')
# student4 = group1.users.create(first_name: 'Arthur',last_name: 'Li', email: 'arthur@edcellent.com',password: '12345678', user_access: 1, school: 'Wesley', year_level: 'Year 11', wechat_account: 'hehe4', phone_number: '0417313115')
# student5 = group1.users.create(first_name: 'Kim',last_name: 'Li',email: 'kim@edcellent.com',password: '12345678', user_access: 1, school: 'Wesley', year_level: 'Year 11', wechat_account: 'hehe5', phone_number: '0417313116')
# puts "#{User.where(user_access: 'student').count} students have been created."

# #create tutors
# tutor1 = User.create(first_name: 'Carolyn', last_name: 'Zhang',email: 'carolyn@edcellent.com',password: '12345678', user_access: 2)
# tutor2 = User.create(first_name: 'Sam',last_name: 'S', email: 'sam@edcellent.com',password: '12345678', user_access: 2)
# tutor3 = User.create(first_name: 'Wynn',last_name: 'Chen', email: 'wynn@edcellent.com',password: '12345678', user_access: 2)
# tutor4 = User.create(first_name: 'Mary',last_name: 'M', email: 'mary@edcellent.com',password: '12345678', user_access: 2)
# puts "#{User.where(user_access: 'tutor').count} tutors have been created."

# admin1 = User.create(first_name: 'Desmond',last_name: 'K', email: 'noone.knowu@gmail.com',password: '12345678', user_access: 0)
# admin2 = User.create(first_name: 'Carlyn',last_name: 'K', email: 'carlyn@edcellent.com',password: '12345678', user_access: 0)
# puts "#{User.where(user_access: 'admin').count} admin have been created."

# #create sessions
# # session1 = Period.create(period_status: 0, subject: 'EAL', description: 'listening text', note: 'student is good', group_id: group1.id, tutor_id: tutor1.id, start_time: "2017-09-30T13:30:00+10:00", end_time: "2017-09-30T15:00:00+10:00")
# # session2 = Period.create(period_status: 0, subject: 'EAL', description: 'text response', note: 'student is ok', group_id: group1.id, tutor_id: tutor1.id, start_time: "2017-10-01T13:30:00+10:00", end_time: "2017-10-01T15:00:00+10:00")
# # session3 = Period.create(period_status: 0, subject: 'EAL', description: 'essay', note: 'student is alright', group_id: group1.id, tutor_id: tutor1.id, start_time: "2017-09-30T13:30:00+10:00", end_time: "2017-09-30T15:00:00+10:00")
# # session4 = Period.create(period_status: 0, subject: 'EAL', description: 'oral', note: 'student is alright', group_id: group1.id, tutor_id: tutor1.id, start_time: "2017-10-03T09:30:00+10:00", end_time: "2017-10-03T12:00:00+10:00")
# # session5 = Period.create(period_status: 1, subject: 'EAL', description: 'oral', note: 'student is alright', group_id: group2.id, tutor_id: tutor2.id, start_time: "2017-10-03T13:30:00+10:00", end_time: "2017-10-03T15:00:00+10:00")
# # session6 = Period.create(period_status: 1, subject: 'EAL', description: 'oral', note: 'student is alright', group_id: group3.id, tutor_id: tutor3.id, start_time: "2017-10-04T13:30:00+10:00", end_time: "2017-10-04T15:00:00+10:00")
# # session7 = Period.create(period_status: 1, subject: 'EAL', description: 'oral', note: 'student is alright', group_id: group3.id, tutor_id: tutor4.id, start_time: "2017-10-05T13:30:00+10:00", end_time: "2017-10-05T15:00:00+10:00")
# # session8 = Period.create(period_status: 1, subject: 'EAL', description: 'oral', note: 'student is alright', group_id: random_group1.id, tutor_id: tutor2.id, start_time: "2017-10-06T13:30:00+10:00", end_time: "2017-10-06T15:00:00+10:00")
# # puts "#{Period.all.count} sessions have been created."

# puts "done"

# User.create(first_name: 'KY', last_name: 'Kang',email: 'kai@edcellent.com',password: '12345678', user_access: 2)

# puts "populate wynn's students"

# CSV.foreach('db/w-students.csv', :headers => true) do |row|
#   u = User.new(row.to_hash)
#   u.user_access = 1
#   u.password = 'bangbangda12345678!'
#   unless User.find_by(email: u.email)
#     u.save
#     puts "#{u.english_name} is saved!"
#   end
# end

# puts "populate carolyn's students"

# CSV.foreach('db/cz-students.csv', :headers => true) do |row|
#   u = User.new(row.to_hash)
#   u.user_access = 1
#   u.password = 'bangbangda12345678!'
#   unless User.find_by(email: u.email)
#     u.save
#     puts "#{u.english_name} is saved!"
#   end
# end
num = 0

CSV.foreach('db/students.csv', :headers => true) do |row|
  u = User.new(row.to_hash)
  u.user_access = 1
  u.password = 'bangbangda12345678!'
  u.phone_number = "0" + u.phone_number
  unless User.find_by(email: u.email)
    if u.save
      puts "#{u.english_name} is saved!"
      num += 1
    end
  end
end

puts "#{num} students have been created"


