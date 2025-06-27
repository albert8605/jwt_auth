defmodule JwtAuthProject.Repo.Migrations.CreateUserBlacklists do
  use Ecto.Migration

  def change do
    create table(:user_blacklists) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :reason, :string
      add :blacklisted_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_blacklists, [:user_id])
  end
end
