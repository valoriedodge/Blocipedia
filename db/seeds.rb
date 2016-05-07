require 'random_data'

10.times do
  User.create!(
    email: Faker::Internet.email,
    password: Faker::Internet.password
  )
end

users = User.all

30.times do
  Wiki.create!(
    title: Faker::Lorem.sentence,
    body: Faker::Lorem.paragraph,
    user: users.sample
  )
end

wikis = Wiki.all

puts "Seed finished"
puts "#{User.count} users created"
puts "#{Wiki.count} wikis created"
