defmodule JwtAuthProject.Repo.Migrations.AddRoleIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role_id, references(:roles, on_delete: :nothing), null: false
      remove :role
    end
  end
end
