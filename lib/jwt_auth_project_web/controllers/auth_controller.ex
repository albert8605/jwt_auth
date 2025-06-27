defmodule JwtAuthProjectWeb.AuthController do
  use JwtAuthProjectWeb, :controller

  # POST /api/login
  def login(conn, %{"username" => username, "password" => password}) do
    user = JwtAuthProject.Accounts.get_user_by_username_and_password(username, password)
    handle_login_response(conn, user)
  end

  def login(conn, %{"email" => email, "password" => password}) do
    user = JwtAuthProject.Accounts.get_user_by_email_or_username_and_password(email, password)
    handle_login_response(conn, user)
  end

  def login(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing username/email or password"})
  end

  defp handle_login_response(conn, user) do
    cond do
      is_nil(user) ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
      JwtAuthProject.Accounts.user_blacklisted?(user.id) ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "User is blacklisted"})
      is_nil(user.role) ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "No role assigned"})
      true ->
        token = JwtAuthProject.JWTAuth.generate_token(%{"sub" => user.username, "role" => user.role.name})
        json(conn, %{token: token, user: %{id: user.id, username: user.username, email: user.email, role: user.role.name}})
    end
  end

  # POST /api/verify
  def verify(conn, %{"token" => token}) when token == "" do
    conn
    |> put_status(:bad_request)
    |> json(%{valid: false, error: "Token is required"})
  end

  def verify(conn, %{"token" => token}) do
    case JwtAuthProject.JWTAuth.verify_token(token) do
      {:ok, claims} ->
        username = claims["sub"]
        jwt_role = claims["role"]
        user = JwtAuthProject.Accounts.get_user_by_username_with_role(username)
        cond do
          is_nil(user) ->
            conn
            |> put_status(:unauthorized)
            |> json(%{valid: false, error: "User not found in database"})
          JwtAuthProject.Accounts.user_blacklisted?(user.id) ->
            conn
            |> put_status(:forbidden)
            |> json(%{valid: false, error: "User is blacklisted (db)"})
          is_nil(user.role) ->
            conn
            |> put_status(:forbidden)
            |> json(%{valid: false, error: "No role assigned in database"})
          user.role.name != jwt_role ->
            conn
            |> put_status(:forbidden)
            |> json(%{valid: false, error: "Role in token does not match database"})
          true ->
            json(conn, %{valid: true, claims: claims, user: %{id: user.id, username: user.username, role: user.role.name}})
        end
      {:error, :blacklisted_user} ->
        conn
        |> put_status(:forbidden)
        |> json(%{valid: false, error: "User is blacklisted"})
      {:error, :no_role_assigned} ->
        conn
        |> put_status(:forbidden)
        |> json(%{valid: false, error: "No role assigned in token"})
      {:error, :token_expired} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{valid: false, error: "Token expired"})
      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{valid: false, error: "Invalid or expired token"})
    end
  end

  def verify(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{valid: false, error: "Token is required"})
  end

  def verify_token_for_live(token) do
    case JwtAuthProject.JWTAuth.verify_token(token) do
      {:ok, claims} ->
        username = claims["sub"]
        jwt_role = claims["role"]
        user = JwtAuthProject.Accounts.get_user_by_username_with_role(username)
        cond do
          is_nil(user) ->
            {:error, "User not found in database"}
          JwtAuthProject.Accounts.user_blacklisted?(user.id) ->
            {:error, "User is blacklisted (db)"}
          is_nil(user.role) ->
            {:error, "No role assigned in database"}
          user.role.name != jwt_role ->
            {:error, "Role in token does not match database"}
          true ->
            {:ok, claims}
        end
      {:error, :blacklisted_user} ->
        {:error, "User is blacklisted"}
      {:error, :no_role_assigned} ->
        {:error, "No role assigned in token"}
      {:error, :token_expired} ->
        {:error, "Token expired"}
      {:error, _} ->
        {:error, "Invalid or expired token"}
    end
  end
end
