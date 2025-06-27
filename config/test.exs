import Config

# Configure your database
config :jwt_auth_project, JwtAuthProject.Repo,
  username: "admin",
  password: "admin123",
  hostname: "127.0.0.1",
  database: "jwt_users",
  port: "5432",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :jwt_auth_project, JwtAuthProjectWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "HN4z+/S4VtUOhGuQ3yPTSrbirEm0nvGxWg973+qh90QS9VYkMTWC7e4rxh008UE3",
  server: false

# In test we don't send emails
config :jwt_auth_project, JwtAuthProject.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
