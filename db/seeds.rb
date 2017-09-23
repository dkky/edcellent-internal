# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#create groups
group1 = Group.create(name: 'First Group')
group2 = Group.create(name: 'Individual 1')
group3 = Group.create(name: 'Individual 2')
puts "#{Group.all.count} groups have been created."
#create students
student1 = group2.users.create(first_name: 'Tim', last_name: 'Li', email: 'tim@edcellent.com',password: '12345678',user_access: 1, school: 'Wesley', year_level: 'Year 11', wechat_account: 'hehe1', phone_number: '0417313112')
student2 = group3.users.create(first_name: 'Kenny', last_name: 'Li', email: 'kenny@edcellent.com',password: '12345678', user_access: 1, school: 'Wesley', year_level: 'Year 12', wechat_account: 'hehe2', phone_number: '0417313113')
student3 = group1.users.create(first_name: 'James',last_name: 'Li',email: 'james@edcellent.com',password: '12345678', user_access: 1, school: 'Wesley', year_level: 'Year 10', wechat_account: 'hehe3', phone_number: '0417313114')
student4 = group1.users.create(first_name: 'Arthur',last_name: 'Li', email: 'arthur@edcellent.com',password: '12345678', user_access: 1, school: 'Wesley', year_level: 'Year 11', wechat_account: 'hehe4', phone_number: '0417313115')
student5 = group1.users.create(first_name: 'Kim',last_name: 'Li',email: 'kim@edcellent.com',password: '12345678', user_access: 1, school: 'Wesley', year_level: 'Year 11', wechat_account: 'hehe5', phone_number: '0417313116')
puts "#{User.where(user_access: 'student').count} students have been created."


#create tutors
tutor1 = User.create(first_name: 'Carolyn', last_name: 'Zhang',email: 'carolyn@edcellent.com',password: '12345678', user_access: 2)
tutor2 = User.create(first_name: 'Sam',last_name: 'S', email: 'sam@edcellent.com',password: '12345678', user_access: 2)
puts "#{User.where(user_access: 'tutor').count} tutors have been created."

admin1 = User.create(first_name: 'Desmond',last_name: 'K', email: 'desmond@edcellent.com',password: '12345678', user_access: 0)
puts "#{User.where(user_access: 'admin').count} admin have been created."

#create sessions
session1 = Period.create(period_status: 0, subject: 'EAL', description: 'listening text', note: 'student is good', group_id: group1.id, tutor_id: tutor1.id, start_time: "2017-09-10 01:30 +05:30", end_time: "2017-09-10 02:30 +05:30")
session2 = Period.create(period_status: 0, subject: 'EAL', description: 'text response', note: 'student is ok', group_id: group1.id, tutor_id: tutor1.id, start_time: "2017-09-11 01:30 +05:30", end_time: "2017-09-11 02:30 +05:30")
session3 = Period.create(period_status: 0, subject: 'EAL', description: 'essay', note: 'student is alright', group_id: group1.id, tutor_id: tutor1.id, start_time: "2017-09-11 01:30 +05:30", end_time: "2017-09-11 02:30 +05:30")
session4 = Period.create(period_status: 0, subject: 'EAL', description: 'oral', note: 'student is alright', group_id: group1.id, tutor_id: tutor1.id, start_time: "2017-09-11 01:30 +05:30", end_time: "2017-09-11 02:30 +05:30")
session5 = Period.create(period_status: 1, subject: 'EAL', description: 'oral', note: 'student is alright', group_id: group2.id, tutor_id: tutor2.id, start_time: "2017-09-12 01:30 +05:30", end_time: "2017-09-11 01:30 +05:30")
session6 = Period.create(period_status: 1, subject: 'EAL', description: 'oral', note: 'student is alright', group_id: group2.id, tutor_id: tutor2.id, start_time: "2017-09-13 01:30 +05:30", end_time: "2017-09-11 05:30 +05:30")
session7 = Period.create(period_status: 1, subject: 'EAL', description: 'oral', note: 'student is alright', group_id: group2.id, tutor_id: tutor2.id, start_time: "2017-09-14 01:30 +05:30", end_time: "2017-09-11 06:30 +05:30")
session8 = Period.create(period_status: 1, subject: 'EAL', description: 'oral', note: 'student is alright', group_id: group2.id, tutor_id: tutor2.id, start_time: "2017-09-15 01:30 +05:30", end_time: "2017-09-11 07:30 +05:30")
puts "#{Period.all.count} sessions have been created."


puts "done"