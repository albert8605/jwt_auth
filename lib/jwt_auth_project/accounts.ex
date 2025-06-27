defmodule JwtAuthProject.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias JwtAuthProject.Repo

  alias JwtAuthProject.Accounts.User
  alias JwtAuthProject.Accounts.UserBlacklist
  alias JwtAuthProject.Accounts.Role

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_user_with_password(attrs \\ %{}) do
    # Hash the password if provided
    attrs = if Map.has_key?(attrs, :password) do
      password_hash = Pbkdf2.hash_pwd_salt(attrs.password)
      attrs
      |> Map.put(:password_hash, password_hash)
      |> Map.delete(:password)
    else
      attrs
    end

    create_user(attrs)
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def get_user_by_username_with_role(username) do
    import Ecto.Query
    Repo.one(from u in User, where: u.username == ^username, preload: [:role])
  end

  def get_user_by_username_and_password(username, password) do
    import Ecto.Query
    user = Repo.one(from u in User, where: u.username == ^username, preload: [:role])
    if user && Pbkdf2.verify_pass(password, user.password_hash) do
      user
    else
      nil
    end
  end

  def get_user_by_email_or_username_and_password(email_or_username, password) do
    import Ecto.Query
    user = Repo.one(from u in User,
      where: u.username == ^email_or_username or u.email == ^email_or_username,
      preload: [:role])
    if user && Pbkdf2.verify_pass(password, user.password_hash) do
      user
    else
      nil
    end
  end

  def user_blacklisted?(user_id) do
    import Ecto.Query
    Repo.exists?(from b in UserBlacklist, where: b.user_id == ^user_id)
  end

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{name: "admin"})
      {:ok, %Role{}}

      iex> create_role(%{name: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a role by name.

  ## Examples

      iex> get_role_by_name("admin")
      %Role{}

      iex> get_role_by_name("nonexistent")
      nil

  """
  def get_role_by_name(name) do
    import Ecto.Query
    Repo.one(from r in Role, where: r.name == ^name)
  end

  @doc """
  Creates a user blacklist entry.

  ## Examples

      iex> create_user_blacklist(%{user_id: 123})
      {:ok, %UserBlacklist{}}

      iex> create_user_blacklist(%{user_id: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_blacklist(attrs \\ %{}) do
    %UserBlacklist{}
    |> UserBlacklist.changeset(attrs)
    |> Repo.insert()
  end
end
