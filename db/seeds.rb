require 'random_data'

10.times do
  User.create!(
    email: RandomData.random_email,
    password: RandomData.random_sentence
  )
end

users = User.all

30.times do
  Wiki.create!(
    title: RandomData.random_sentence,
    body: RandomData.random_paragraph,
    user: users.sample
  )
end

wikis = Wiki.all

puts "Seed finished"
puts "#{User.count} users created"
puts "#{Wiki.count} wikis created"
