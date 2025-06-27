defmodule JwtAuthProject.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :password_hash, :string
    field :is_active, :boolean, default: false
    field :is_blacklisted, :boolean, default: false
    belongs_to :role, JwtAuthProject.Accounts.Role

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password_hash, :is_active, :is_blacklisted, :role_id])
    |> validate_required([:username, :email, :password_hash, :is_active, :is_blacklisted, :role_id])
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end
end
