defmodule JwtAuthProject.TestHelpers do
  @moduledoc """
  Helper functions for testing the JWT authentication project.
  """

  import ExUnit.Assertions
  alias JwtAuthProject.JWTAuth

  @doc """
  Generates a valid JWT token for testing.
  """
  def generate_test_token(username \\ "testuser", role \\ "user") do
    JWTAuth.generate_token(%{"sub" => username, "role" => role})
  end

  @doc """
  Generates an expired JWT token for testing.
  """
  def generate_expired_token(username \\ "testuser", role \\ "user") do
    exp_time = DateTime.utc_now() |> DateTime.add(-3600, :second) |> DateTime.to_unix()
    JWTAuth.generate_token(%{"sub" => username, "role" => role, "exp" => exp_time})
  end

  @doc """
  Generates a token for a blacklisted user.
  """
  def generate_blacklisted_token do
    JWTAuth.generate_token(%{"sub" => "banned_user", "role" => "user"})
  end

  @doc """
  Generates a token without a role.
  """
  def generate_token_without_role(username \\ "testuser") do
    JWTAuth.generate_token(%{"sub" => username})
  end

  @doc """
  Validates that a response contains expected error fields.
  """
  def assert_validation_errors(response, expected_errors) do
    Enum.each(expected_errors, fn {field, message} ->
      assert response =~ message
      assert response =~ field
    end)
  end

  @doc """
  Validates that a response contains expected success fields.
  """
  def assert_success_response(response, expected_fields) do
    Enum.each(expected_fields, fn field ->
      assert response =~ field
    end)
  end

  @doc """
  Validates username format according to the current regex.
  """
  def valid_username?(username) do
    Regex.match?(~r/^[A-Za-z0-9_]+$/, username)
  end

  @doc """
  Validates password format according to the current regex.
  """
  def valid_password?(password) do
    Regex.match?(~r/^[A-Za-z0-9_]{8,}$/, password)
  end

  @doc """
  Validates email format according to the current regex.
  """
  def valid_email?(email) do
    Regex.match?(~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/u, email)
  end

  @doc """
  Generates test data for different validation scenarios.
  """
  def generate_validation_test_data do
    %{
      valid_usernames: ["user123", "test_user", "User123", "123456", "user"],
      invalid_usernames: ["user-123", "user@123", "user.123", "user 123", "user#123"],
      valid_passwords: ["password123", "pass_word123", "Password123", "12345678", "pass123word"],
      invalid_passwords: ["short", "pass@word", "pass-word", "pass word", "pass#word"],
      valid_emails: [
        "test@example.com",
        "user.name@domain.co.uk",
        "user+tag@example.com",
        "user123@test-domain.org"
      ],
      invalid_emails: [
        "invalid-email",
        "test@",
        "@example.com",
        "test..user@example.com",
        "test@.com"
      ]
    }
  end
end
