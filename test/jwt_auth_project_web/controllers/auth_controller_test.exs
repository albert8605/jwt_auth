defmodule JwtAuthProjectWeb.AuthControllerTest do
  use JwtAuthProjectWeb.ConnCase

  alias JwtAuthProject.Accounts

  setup do
    # Create roles for testing - use unique names to avoid conflicts
    unique_id = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)

    # Try to create roles, handle case where they might already exist
    role = case Accounts.create_role(%{name: "user_#{unique_id}"}) do
      {:ok, role} -> role
      {:error, _} ->
        # If creation fails, try to get existing role or create with different name
        case Accounts.get_role_by_name("user") do
          nil ->
            {:ok, role} = Accounts.create_role(%{name: "user_test_#{unique_id}"})
            role
          role -> role
        end
    end

    admin_role = case Accounts.create_role(%{name: "admin_#{unique_id}"}) do
      {:ok, role} -> role
      {:error, _} ->
        case Accounts.get_role_by_name("admin") do
          nil ->
            {:ok, role} = Accounts.create_role(%{name: "admin_test_#{unique_id}"})
            role
          role -> role
        end
    end

    # Create test users with unique identifiers
    {:ok, user} = Accounts.create_user_with_password(%{
      username: "testuser_#{unique_id}",
      email: "test_#{unique_id}@example.com",
      password: "password123",
      role_id: role.id
    })

    {:ok, admin_user} = Accounts.create_user_with_password(%{
      username: "admin_#{unique_id}",
      email: "admin_#{unique_id}@example.com",
      password: "admin123",
      role_id: admin_role.id
    })

    {:ok, user_with_underscore} = Accounts.create_user_with_password(%{
      username: "test_user_#{unique_id}",
      email: "test_user_#{unique_id}@example.com",
      password: "pass_word123",
      role_id: role.id
    })

    %{
      user: user,
      admin_user: admin_user,
      user_with_underscore: user_with_underscore,
      role: role,
      admin_role: admin_role,
      unique_id: unique_id
    }
  end

  describe "POST /api/login" do
    test "login with valid username and password", %{conn: conn, user: user, unique_id: unique_id} do
      conn = post(conn, ~p"/api/login", %{
        "username" => "testuser_#{unique_id}",
        "password" => "password123"
      })

      assert json_response(conn, 200)
      response = json_response(conn, 200)
      assert response["token"]
      assert response["user"]["id"] == user.id
      assert response["user"]["username"] == "testuser_#{unique_id}"
      assert response["user"]["email"] == "test_#{unique_id}@example.com"
      assert response["user"]["role"] == "user_#{unique_id}"
    end

    test "login with valid email and password", %{conn: conn, user: user, unique_id: unique_id} do
      conn = post(conn, ~p"/api/login", %{
        "email" => "test_#{unique_id}@example.com",
        "password" => "password123"
      })

      assert json_response(conn, 200)
      response = json_response(conn, 200)
      assert response["token"]
      assert response["user"]["id"] == user.id
      assert response["user"]["username"] == "testuser_#{unique_id}"
      assert response["user"]["email"] == "test_#{unique_id}@example.com"
      assert response["user"]["role"] == "user_#{unique_id}"
    end

    test "login with username containing underscore", %{conn: conn, user_with_underscore: user, unique_id: unique_id} do
      conn = post(conn, ~p"/api/login", %{
        "username" => "test_user_#{unique_id}",
        "password" => "pass_word123"
      })

      assert json_response(conn, 200)
      response = json_response(conn, 200)
      assert response["token"]
      assert response["user"]["id"] == user.id
      assert response["user"]["username"] == "test_user_#{unique_id}"
      assert response["user"]["role"] == "user_#{unique_id}"
    end

    test "login with password containing underscore", %{conn: conn, user_with_underscore: user, unique_id: unique_id} do
      conn = post(conn, ~p"/api/login", %{
        "username" => "test_user_#{unique_id}",
        "password" => "pass_word123"
      })

      assert json_response(conn, 200)
      response = json_response(conn, 200)
      assert response["token"]
      assert response["user"]["id"] == user.id
    end

    test "login with invalid username", %{conn: conn} do
      conn = post(conn, ~p"/api/login", %{
        "username" => "nonexistent",
        "password" => "password123"
      })

      assert json_response(conn, 401)
      response = json_response(conn, 401)
      assert response["error"] == "Invalid credentials"
    end

    test "login with invalid password", %{conn: conn, unique_id: unique_id} do
      conn = post(conn, ~p"/api/login", %{
        "username" => "testuser_#{unique_id}",
        "password" => "wrongpassword"
      })

      assert json_response(conn, 401)
      response = json_response(conn, 401)
      assert response["error"] == "Invalid credentials"
    end

    test "login with invalid email", %{conn: conn} do
      conn = post(conn, ~p"/api/login", %{
        "email" => "wrong@example.com",
        "password" => "password123"
      })

      assert json_response(conn, 401)
      response = json_response(conn, 401)
      assert response["error"] == "Invalid credentials"
    end

    test "login with missing username/email", %{conn: conn} do
      conn = post(conn, ~p"/api/login", %{
        "password" => "password123"
      })

      assert json_response(conn, 400)
      response = json_response(conn, 400)
      assert response["error"] == "Missing username/email or password"
    end

    test "login with missing password", %{conn: conn, unique_id: unique_id} do
      conn = post(conn, ~p"/api/login", %{
        "username" => "testuser_#{unique_id}"
      })

      assert json_response(conn, 400)
      response = json_response(conn, 400)
      assert response["error"] == "Missing username/email or password"
    end

    test "login with empty parameters", %{conn: conn} do
      conn = post(conn, ~p"/api/login", %{})

      assert json_response(conn, 400)
      response = json_response(conn, 400)
      assert response["error"] == "Missing username/email or password"
    end
  end

  describe "POST /api/verify" do
    test "verify valid token", %{conn: conn, user: user, unique_id: unique_id} do
      # First login to get a token
      login_conn = post(conn, ~p"/api/login", %{
        "username" => "testuser_#{unique_id}",
        "password" => "password123"
      })

      login_response = json_response(login_conn, 200)
      token = login_response["token"]

      # Now verify the token
      verify_conn = post(conn, ~p"/api/verify", %{"token" => token})

      assert json_response(verify_conn, 200)
      response = json_response(verify_conn, 200)
      assert response["valid"] == true
      assert response["claims"]["sub"] == "testuser_#{unique_id}"
      assert response["claims"]["role"] == "user_#{unique_id}"
      assert response["user"]["id"] == user.id
      assert response["user"]["username"] == "testuser_#{unique_id}"
      assert response["user"]["role"] == "user_#{unique_id}"
    end

    test "verify token with admin role", %{conn: conn, admin_user: user, unique_id: unique_id} do
      # First login to get a token
      login_conn = post(conn, ~p"/api/login", %{
        "username" => "admin_#{unique_id}",
        "password" => "admin123"
      })

      login_response = json_response(login_conn, 200)
      token = login_response["token"]

      # Now verify the token
      verify_conn = post(conn, ~p"/api/verify", %{"token" => token})

      assert json_response(verify_conn, 200)
      response = json_response(verify_conn, 200)
      assert response["valid"] == true
      assert response["claims"]["sub"] == "admin_#{unique_id}"
      assert response["claims"]["role"] == "admin_#{unique_id}"
      assert response["user"]["id"] == user.id
      assert response["user"]["username"] == "admin_#{unique_id}"
      assert response["user"]["role"] == "admin_#{unique_id}"
    end

    test "verify invalid token", %{conn: conn} do
      conn = post(conn, ~p"/api/verify", %{"token" => "invalid_token"})

      assert json_response(conn, 401)
      response = json_response(conn, 401)
      assert response["error"] == "Invalid or expired token"
    end

    test "verify expired token", %{conn: conn, user: _user, unique_id: unique_id} do
      # Create an expired token
      expired_payload = %{
        "sub" => "testuser_#{unique_id}",
        "role" => "user_#{unique_id}",
        "exp" => DateTime.utc_now() |> DateTime.add(-1, :second) |> DateTime.to_unix()
      }
      expired_token = JwtAuthProject.JWTAuth.generate_token(expired_payload)

      conn = post(conn, ~p"/api/verify", %{"token" => expired_token})

      assert json_response(conn, 401)
      response = json_response(conn, 401)
      assert response["error"] == "Token expired"
    end

    test "verify token for non-existent user", %{conn: conn} do
      # Create a token for a non-existent user
      fake_payload = %{
        "sub" => "nonexistent",
        "role" => "user",
        "exp" => DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.to_unix()
      }
      token = JwtAuthProject.JWTAuth.generate_token(fake_payload)

      conn = post(conn, ~p"/api/verify", %{"token" => token})

      assert json_response(conn, 401)
      response = json_response(conn, 401)
      assert response["error"] == "User not found in database"
    end

    test "verify token with empty token", %{conn: conn} do
      conn = post(conn, ~p"/api/verify", %{"token" => ""})

      assert json_response(conn, 400)
      response = json_response(conn, 400)
      assert response["error"] == "Token is required"
    end

    test "verify token with missing token parameter", %{conn: conn} do
      conn = post(conn, ~p"/api/verify", %{})

      assert json_response(conn, 400)
      response = json_response(conn, 400)
      assert response["error"] == "Token is required"
    end
  end

  describe "User blacklisting" do
    test "login with blacklisted user", %{conn: conn, user: user, unique_id: unique_id} do
      # Blacklist the user
      {:ok, _blacklist} = Accounts.create_user_blacklist(%{
        user_id: user.id,
        reason: "Test blacklist",
        blacklisted_at: DateTime.utc_now()
      })

      conn = post(conn, ~p"/api/login", %{
        "username" => "testuser_#{unique_id}",
        "password" => "password123"
      })

      assert json_response(conn, 403)
      response = json_response(conn, 403)
      assert response["error"] == "User is blacklisted"
    end

    test "verify token for blacklisted user", %{conn: conn, user: user, unique_id: unique_id} do
      # First login to get a token
      login_conn = post(conn, ~p"/api/login", %{
        "username" => "testuser_#{unique_id}",
        "password" => "password123"
      })

      login_response = json_response(login_conn, 200)
      token = login_response["token"]

      # Blacklist the user
      {:ok, _blacklist} = Accounts.create_user_blacklist(%{
        user_id: user.id,
        reason: "Test blacklist",
        blacklisted_at: DateTime.utc_now()
      })

      # Try to verify the token
      verify_conn = post(conn, ~p"/api/verify", %{"token" => token})

      assert json_response(verify_conn, 403)
      response = json_response(verify_conn, 403)
      assert response["error"] == "User is blacklisted (db)"
    end
  end

  describe "Role validation" do
    test "verify token with role mismatch", %{conn: conn, user: user, unique_id: unique_id} do
      # First login to get a token
      login_conn = post(conn, ~p"/api/login", %{
        "username" => "testuser_#{unique_id}",
        "password" => "password123"
      })

      login_response = json_response(login_conn, 200)
      token = login_response["token"]

      # Change the user's role in the database
      {:ok, admin_role} = Accounts.create_role(%{name: "admin_test_#{unique_id}"})
      {:ok, _updated_user} = Accounts.update_user(user, %{role_id: admin_role.id})

      # Try to verify the token (should fail as role in token doesn't match database)
      verify_conn = post(conn, ~p"/api/verify", %{"token" => token})

      assert json_response(verify_conn, 403)
      response = json_response(verify_conn, 403)
      assert response["error"] == "Role in token does not match database"
    end
  end
end
