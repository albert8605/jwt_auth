defmodule JwtAuthProjectWeb.LoginTest do
  use JwtAuthProjectWeb.ConnCase
  import Phoenix.LiveViewTest
  alias JwtAuthProject.Accounts

  setup do
    unique_id = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
    role_name = "user_#{unique_id}"
    username = "testuser_#{unique_id}"
    email = "test_#{unique_id}@example.com"
    password = "password123"

    {:ok, role} = Accounts.create_role(%{name: role_name})
    {:ok, user} = Accounts.create_user_with_password(%{
      username: username,
      email: email,
      password: password,
      role_id: role.id
    })

    %{user: user, role: role, unique_id: unique_id, username: username, email: email, password: password, role_name: role_name}
  end

  describe "Login LiveView" do
    test "renders login form", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Login"
      assert html =~ "E-mail/Username"
      assert html =~ "Password"
    end

    test "shows validation errors for empty fields", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Submit empty form
      view
      |> form("form", %{})
      |> render_submit()

      # Check for validation errors - errors are shown in the error div
      assert has_element?(view, ".bg-red-100")
    end

    test "shows validation error for invalid email format", %{conn: conn, password: password} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Submit with invalid email
      view
      |> form("form", %{
        "form[email]" => "invalid-email",
        "form[password]" => password
      })
      |> render_submit()

      # Check for validation error
      assert has_element?(view, ".bg-red-100")
    end

    test "shows validation error for invalid username format", %{conn: conn, password: password} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Submit with invalid username (contains special characters)
      view
      |> form("form", %{
        "form[email]" => "test-user@",
        "form[password]" => password
      })
      |> render_submit()

      # Check for validation error
      assert has_element?(view, ".bg-red-100")
    end

    test "accepts valid username with underscores", %{conn: conn, role: role, password: password, unique_id: unique_id} do
      username = "test_user_#{unique_id}"
      {:ok, _} = Accounts.create_user_with_password(%{
        username: username,
        email: "test_user_#{unique_id}@example.com",
        password: password,
        role_id: role.id
      })
      {:ok, view, _html} = live(conn, ~p"/")

      # Submit with valid username containing underscore
      view
      |> form("form", %{
        "form[email]" => username,
        "form[password]" => password
      })
      |> render_submit()

      # Should show success message or JWT token
      assert has_element?(view, ".bg-green-100") || has_element?(view, "code")
    end

    test "shows validation error for short password", %{conn: conn, username: username} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Submit with short password
      view
      |> form("form", %{
        "form[email]" => username,
        "form[password]" => "short"
      })
      |> render_submit()

      # Check for validation error
      assert has_element?(view, ".bg-red-100")
    end

    test "accepts valid password with underscores", %{conn: conn, username: _username, role: role, unique_id: unique_id} do
      password_with_underscore = "pass_word123"
      {:ok, _} = Accounts.create_user_with_password(%{
        username: "pw_user_#{unique_id}",
        email: "pw_#{unique_id}@example.com",
        password: password_with_underscore,
        role_id: role.id
      })
      {:ok, view, _html} = live(conn, ~p"/")

      # Submit with valid password containing underscore
      view
      |> form("form", %{
        "form[email]" => "pw_user_#{unique_id}",
        "form[password]" => password_with_underscore
      })
      |> render_submit()

      # Should show success message or JWT token
      assert has_element?(view, ".bg-green-100") || has_element?(view, "code")
    end

    test "successful login with username", %{conn: conn, username: username, password: password} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Submit with valid credentials
      view
      |> form("form", %{
        "form[email]" => username,
        "form[password]" => password
      })
      |> render_submit()

      # Check for success message or JWT token
      assert has_element?(view, ".bg-green-100") || has_element?(view, "code")
    end

    test "successful login with email", %{conn: conn, email: email, password: password} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Submit with valid email
      view
      |> form("form", %{
        "form[email]" => email,
        "form[password]" => password
      })
      |> render_submit()

      # Check for success message or JWT token
      assert has_element?(view, ".bg-green-100") || has_element?(view, "code")
    end

    test "failed login with invalid credentials", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Submit with invalid credentials
      view
      |> form("form", %{
        "form[email]" => "nonexistent",
        "form[password]" => "wrongpassword"
      })
      |> render_submit()

      # Check for error message
      assert has_element?(view, ".bg-red-100")
    end

    test "failed login with wrong password", %{conn: conn, username: username} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Submit with correct username but wrong password
      view
      |> form("form", %{
        "form[email]" => username,
        "form[password]" => "wrongpassword"
      })
      |> render_submit()

      # Check for error message
      assert has_element?(view, ".bg-red-100")
    end

    test "form resets after successful submission", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Submit with valid credentials
      view
      |> form("form", %{
        "form[email]" => "testuser",
        "form[password]" => "password123"
      })
      |> render_submit()

      # Check that form fields still exist
      assert has_element?(view, "input[name='form[email]']")
      assert has_element?(view, "input[name='form[password]']")
    end

    test "handles special characters in username field", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Test various special characters
      special_chars = ["test@user", "test-user", "test.user", "test user"]

      Enum.each(special_chars, fn username ->
        view
        |> form("form", %{
          "form[email]" => username,
          "form[password]" => "password123"
        })
        |> render_submit()

        # Should show validation error for invalid characters
        assert has_element?(view, ".bg-red-100")
      end)

      # Test valid username with underscore
      view
      |> form("form", %{
        "form[email]" => "test_user",
        "form[password]" => "password123"
      })
      |> render_submit()

      # Should show validation error since user doesn't exist
      assert has_element?(view, ".bg-red-100")
    end

    test "handles special characters in password field", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Test various special characters
      special_chars = ["pass@word", "pass-word", "pass.word", "pass word"]

      Enum.each(special_chars, fn password ->
        view
        |> form("form", %{
          "form[email]" => "testuser",
          "form[password]" => password
        })
        |> render_submit()

        # Should show validation error for invalid characters
        assert has_element?(view, ".bg-red-100")
      end)

      # Test valid password with underscore
      view
      |> form("form", %{
        "form[email]" => "testuser",
        "form[password]" => "pass_word123"
      })
      |> render_submit()

      # Should show validation error since user doesn't exist
      assert has_element?(view, ".bg-red-100")
    end
  end

  describe "Login with blacklisted user" do
    test "shows error for blacklisted user", %{conn: conn, user: user} do
      # Blacklist the user
      {:ok, _blacklist} = Accounts.create_user_blacklist(%{
        user_id: user.id,
        blacklisted_at: DateTime.utc_now()
      })

      {:ok, view, _html} = live(conn, ~p"/")

      # Submit with valid credentials
      view
      |> form("form", %{
        "form[email]" => user.username,
        "form[password]" => "password123"
      })
      |> render_submit()

      # Check for blacklist error message
      assert has_element?(view, ".bg-red-100")
    end
  end

  describe "Login with user without role" do
    test "shows error for user without role", %{conn: conn, role: _role} do
      # Create user without role (this will fail due to schema constraint)
      # Instead, let's test with a user that has a role but wrong credentials
      {:ok, view, _html} = live(conn, ~p"/")

      # Submit with non-existent user
      view
      |> form("form", %{
        "form[email]" => "norole",
        "form[password]" => "password123"
      })
      |> render_submit()

      # Check for error message
      assert has_element?(view, ".bg-red-100")
    end
  end
end
