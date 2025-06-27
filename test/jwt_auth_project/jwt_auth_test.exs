defmodule JwtAuthProject.JWTAuthTest do
  use ExUnit.Case
  alias JwtAuthProject.JWTAuth

  describe "generate_token/1" do
    test "generates a valid JWT token" do
      payload = %{"sub" => "testuser", "role" => "user"}
      token = JWTAuth.generate_token(payload)

      assert is_binary(token)
      assert String.length(token) > 0

      # Verify the token can be decoded
      case JWTAuth.verify_token(token) do
        {:ok, claims} ->
          assert claims["sub"] == "testuser"
          assert claims["role"] == "user"
          assert Map.has_key?(claims, "exp")
        _ ->
          flunk("Generated token should be valid")
      end
    end

    test "adds expiration time if not provided" do
      payload = %{"sub" => "testuser", "role" => "user"}
      token = JWTAuth.generate_token(payload)

      case JWTAuth.verify_token(token) do
        {:ok, claims} ->
          assert Map.has_key?(claims, "exp")
          assert is_integer(claims["exp"])
        _ ->
          flunk("Token should have expiration time")
      end
    end

    test "uses provided expiration time" do
      exp_time = DateTime.utc_now() |> DateTime.add(7200, :second) |> DateTime.to_unix()
      payload = %{"sub" => "testuser", "role" => "user", "exp" => exp_time}
      token = JWTAuth.generate_token(payload)

      case JWTAuth.verify_token(token) do
        {:ok, claims} ->
          assert claims["exp"] == exp_time
        _ ->
          flunk("Token should use provided expiration time")
      end
    end

    test "handles empty payload" do
      token = JWTAuth.generate_token(%{})

      assert is_binary(token)
      assert String.length(token) > 0
    end
  end

  describe "verify_token/1" do
    test "verifies a valid token" do
      payload = %{"sub" => "testuser", "role" => "user"}
      token = JWTAuth.generate_token(payload)

      case JWTAuth.verify_token(token) do
        {:ok, claims} ->
          assert claims["sub"] == "testuser"
          assert claims["role"] == "user"
        _ ->
          flunk("Valid token should be verified successfully")
      end
    end

    test "rejects blacklisted users" do
      payload = %{"sub" => "banned_user", "role" => "user"}
      token = JWTAuth.generate_token(payload)

      case JWTAuth.verify_token(token) do
        {:error, :blacklisted_user} ->
          :ok
        _ ->
          flunk("Blacklisted user should be rejected")
      end
    end

    test "rejects users without role" do
      payload = %{"sub" => "testuser"}
      token = JWTAuth.generate_token(payload)

      case JWTAuth.verify_token(token) do
        {:error, :no_role_assigned} ->
          :ok
        _ ->
          flunk("User without role should be rejected")
      end
    end

    test "rejects invalid tokens" do
      invalid_token = "invalid.jwt.token"

      case JWTAuth.verify_token(invalid_token) do
        {:error, :invalid_token} ->
          :ok
        _ ->
          flunk("Invalid token should be rejected")
      end
    end

    test "rejects malformed tokens" do
      malformed_token = "not.a.valid.jwt"

      case JWTAuth.verify_token(malformed_token) do
        {:error, :invalid_token} ->
          :ok
        _ ->
          flunk("Malformed token should be rejected")
      end
    end

    test "rejects tokens with wrong algorithm" do
      # Create a token with a different algorithm (this would require mocking)
      # For now, we'll test with an obviously invalid token
      invalid_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.invalid.signature"

      case JWTAuth.verify_token(invalid_token) do
        {:error, :invalid_token} ->
          :ok
        _ ->
          flunk("Token with wrong algorithm should be rejected")
      end
    end

    test "rejects expired tokens" do
      # Create a token with past expiration
      exp_time = DateTime.utc_now() |> DateTime.add(-3600, :second) |> DateTime.to_unix()
      payload = %{"sub" => "testuser", "role" => "user", "exp" => exp_time}
      token = JWTAuth.generate_token(payload)

      case JWTAuth.verify_token(token) do
        {:error, :token_expired} ->
          :ok
        other ->
          flunk("Expected {:error, :token_expired}, got #{inspect(other)}")
      end
    end

    test "accepts tokens with different roles" do
      roles = ["user", "admin", "moderator", "guest"]

      Enum.each(roles, fn role ->
        payload = %{"sub" => "testuser", "role" => role}
        token = JWTAuth.generate_token(payload)

        case JWTAuth.verify_token(token) do
          {:ok, claims} ->
            assert claims["role"] == role
          _ ->
            flunk("Token with role '#{role}' should be accepted")
        end
      end)
    end

    test "handles tokens with additional claims" do
      payload = %{
        "sub" => "testuser",
        "role" => "user",
        "custom_claim" => "custom_value",
        "nested" => %{"key" => "value"}
      }
      token = JWTAuth.generate_token(payload)

      case JWTAuth.verify_token(token) do
        {:ok, claims} ->
          assert claims["sub"] == "testuser"
          assert claims["role"] == "user"
          assert claims["custom_claim"] == "custom_value"
          assert claims["nested"]["key"] == "value"
        _ ->
          flunk("Token with additional claims should be accepted")
      end
    end
  end

  describe "token lifecycle" do
    test "generated token can be immediately verified" do
      payload = %{"sub" => "testuser", "role" => "user"}
      token = JWTAuth.generate_token(payload)

      # Verify immediately
      case JWTAuth.verify_token(token) do
        {:ok, claims} ->
          assert claims["sub"] == "testuser"
          assert claims["role"] == "user"
        _ ->
          flunk("Freshly generated token should be immediately verifiable")
      end
    end

    test "token contains expected structure" do
      payload = %{"sub" => "testuser", "role" => "user"}
      token = JWTAuth.generate_token(payload)

      case JWTAuth.verify_token(token) do
        {:ok, claims} ->
          # Check required fields
          assert Map.has_key?(claims, "sub")
          assert Map.has_key?(claims, "role")
          assert Map.has_key?(claims, "exp")

          # Check data types
          assert is_binary(claims["sub"])
          assert is_binary(claims["role"])
          assert is_integer(claims["exp"])
        _ ->
          flunk("Token should have expected structure")
      end
    end
  end

  describe "error handling" do
    test "handles nil token" do
      case JWTAuth.verify_token(nil) do
        {:error, :invalid_token} ->
          :ok
        _ ->
          flunk("Nil token should be rejected")
      end
    end

    test "handles empty string token" do
      case JWTAuth.verify_token("") do
        {:error, :invalid_token} ->
          :ok
        _ ->
          flunk("Empty token should be rejected")
      end
    end

    test "handles non-string token" do
      case JWTAuth.verify_token(123) do
        {:error, :invalid_token} ->
          :ok
        _ ->
          flunk("Non-string token should be rejected")
      end
    end
  end

  describe "blacklist functionality" do
    test "rejects all blacklisted usernames" do
      blacklisted_users = ["banned_user", "evil_admin"]

      Enum.each(blacklisted_users, fn username ->
        payload = %{"sub" => username, "role" => "user"}
        token = JWTAuth.generate_token(payload)

        case JWTAuth.verify_token(token) do
          {:error, :blacklisted_user} ->
            :ok
          _ ->
            flunk("Blacklisted user '#{username}' should be rejected")
        end
      end)
    end

    test "accepts non-blacklisted users" do
      valid_users = ["testuser", "admin", "user123", "john_doe"]

      Enum.each(valid_users, fn username ->
        payload = %{"sub" => username, "role" => "user"}
        token = JWTAuth.generate_token(payload)

        case JWTAuth.verify_token(token) do
          {:ok, claims} ->
            assert claims["sub"] == username
          _ ->
            flunk("Non-blacklisted user '#{username}' should be accepted")
        end
      end)
    end
  end
end
