DatabaseCleaner.clean_with(:truncation)

# main user
alice = User.create(
  name: 'Alice',
  email: 'alice@foobar.com',
  password: 'foobar',
  bio: 'Hi, my name is Alice.'
)

# other users
15.times do |n|
  name =     Faker::Name.name
  email =    "foo-#{n}@bar.com"
  password = 'foobar'
  bio =      "Hi, my name is #{name}"
  user = User.create(name: name, email: email, password: password, bio: bio)

  # accepted friends
  if n < 5
    if n.even?
      alice.friendships.create(friend_id: user.id, is_accepted: true)
    else
      user.friendships.create(friend_id: alice.id, is_accepted: true)
    end
  # pending friends
  elsif n < 10
    if n.even?
      alice.friendships.create(friend_id: user.id)
    else
      user.friendships.create(friend_id: alice.id)
    end
  end
end
