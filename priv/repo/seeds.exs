# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     JwtAuthProject.Repo.insert!(%JwtAuthProject.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias JwtAuthProject.Repo
alias JwtAuthProject.Accounts.{User, Role}

# Create roles if they don't exist
admin_role = case Repo.get_by(Role, name: "admin") do
  nil -> Repo.insert!(%Role{name: "admin"})
  role -> role
end

user_role = case Repo.get_by(Role, name: "user") do
  nil -> Repo.insert!(%Role{name: "user"})
  role -> role
end

# Create test users with hashed passwords
test_password = "password123"

# Admin user
_admin_user = case Repo.get_by(User, username: "admin") do
  nil ->
    {:ok, user} = JwtAuthProject.Accounts.create_user_with_password(%{
      username: "admin",
      email: "admin@example.com",
      password: test_password,
      is_active: true,
      is_blacklisted: false,
      role_id: admin_role.id
    })
    user
  user -> user
end

# Regular user
_regular_user = case Repo.get_by(User, username: "user") do
  nil ->
    {:ok, user} = JwtAuthProject.Accounts.create_user_with_password(%{
      username: "user",
      email: "user@example.com",
      password: test_password,
      is_active: true,
      is_blacklisted: false,
      role_id: user_role.id
    })
    user
  user -> user
end

# Another user with different email
_another_user = case Repo.get_by(User, username: "john_doe") do
  nil ->
    {:ok, user} = JwtAuthProject.Accounts.create_user_with_password(%{
      username: "john_doe",
      email: "john@example.com",
      password: test_password,
      is_active: true,
      is_blacklisted: false,
      role_id: user_role.id
    })
    user
  user -> user
end

IO.puts("Seeds completed!")
IO.puts("Test users available:")
IO.puts("  - Username: admin, Email: admin@example.com, Password: #{test_password}")
IO.puts("  - Username: user, Email: user@example.com, Password: #{test_password}")
IO.puts("  - Username: john_doe, Email: john@example.com, Password: #{test_password}")
