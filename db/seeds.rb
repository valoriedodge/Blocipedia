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
    creator: users.sample
  )
end

wikis = Wiki.all

admin = User.create!(
    email:    'admin@example.com',
    password: 'helloworld',
    role:     'admin'
)

premium = User.create!(
    email:    'premium@example.com',
    password: 'helloworld',
    role:     'premium'
)

standard = User.create!(
    email:    'standard@example.com',
    password: 'helloworld'
)


puts "Seed finished"
puts "#{User.count} users created"
puts "#{Wiki.count} wikis created"
