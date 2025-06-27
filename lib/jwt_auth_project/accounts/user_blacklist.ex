defmodule JwtAuthProject.Accounts.UserBlacklist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_blacklists" do
    field :reason, :string
    field :blacklisted_at, :utc_datetime
    belongs_to :user, JwtAuthProject.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(blacklist, attrs) do
    blacklist
    |> cast(attrs, [:user_id, :reason, :blacklisted_at])
    |> validate_required([:user_id, :blacklisted_at])
  end
end
