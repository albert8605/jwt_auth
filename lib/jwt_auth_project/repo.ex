defmodule JwtAuthProject.Repo do
  use Ecto.Repo,
    otp_app: :jwt_auth_project,
    adapter: Ecto.Adapters.Postgres
end
