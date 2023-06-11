users = 10.times.map do
  User.create!(
    email: Faker::Internet.unique.email,
    name: Faker::Name.name,
    password: 'password',
    password_confirmation: 'password'
  )
end

User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password',
  permissions: %w[
    can_list_example_app_pets
    can_view_example_app_pets
    can_edit_example_app_pets
    can_delete_example_app_pets
    can_list_example_app_users
    can_view_example_app_users
    can_edit_example_app_users
    can_delete_example_app_users
  ]
)

1000.times do
  Pet.create!(
    animal: Faker::Creature::Animal.name,
    name: Faker::Name.name,
    date_of_birth: Faker::Date.birthday(min_age: 0, max_age: 21),
    owner: users.sample
  )
end
