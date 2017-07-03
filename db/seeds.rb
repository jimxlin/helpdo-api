DatabaseCleaner.clean_with(:truncation)

# ================= main user ========================
puts "Creating main user..."

alice = User.create(
  name: 'Alice',
  email: 'alice@foobar.com',
  password: 'foobar',
  bio: 'Hi, my name is Alice.'
)

puts "Done!"

# ================ other users ========================
puts "Creating users..."

friends = []
pending_friends = []
non_friends = []

15.times do |n|
  user = FactoryGirl.create(:user)

  # accepted friends
  if n < 5
    if n.even?
      alice.friendships.create!(friend_id: user.id, is_accepted: true)
    else
      user.friendships.create!(friend_id: alice.id, is_accepted: true)
    end
    friends << user
  # pending friends
  elsif n < 10
    if n.even?
      alice.friendships.create!(friend_id: user.id)
    else
      user.friendships.create!(friend_id: alice.id)
    end
    pending_friends << user
  # not friends
  else
    non_friends << user
  end
end

puts "Done!"

# =========================== private todos ======================
print "Creating private todos..."

5.times do
  todo = alice.todos.create(title: Faker::Lorem.word, type: 'PrivateTodo')

  # tasks
  rand(5..10).times do
    task = todo.tasks.create!(name: Faker::Lorem.sentence, is_done: [true, false].sample)
    # make task visible to a random friend (1/3 chance of occurrence)
    task.visibilities.create!(user_id: friends.sample.id) if (rand(1..3) == 1)
  end
end

puts "Done!"


# =========================== public todos ======================
print "Creating public todos..."

5.times do
  todo = alice.todos.create(title: Faker::Lorem.word, type: 'PublicTodo')
  # add three random friends as non-admin members to the todo
  friends.sample(3).each do |friend|
    todo.memberships.create!(user_id: friend.id, is_admin: false)
  end

  # tasks
  rand(5..10).times do
    task = todo.tasks.create!(name: Faker::Lorem.sentence, is_done: [true, false].sample)
    # assign task to a random member (1/3 chance of occurrence)
    task.assignments.create!(user_id: todo.members.sample.id) if (rand(1..3) == 1)
  end
end

puts "Done!"
