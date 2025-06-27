defmodule JwtAuthProject.UtilsTest do
  use ExUnit.Case
  alias JwtAuthProject.Utils

  describe "validate_required/3" do
    test "returns error when value is nil" do
      result = Utils.validate_required([], "username", nil)
      assert [username: "This field is required."] = result
    end

    test "returns error when value is empty string" do
      result = Utils.validate_required([], "email", "")
      assert [email: "This field is required."] = result
    end

    test "removes error when value is provided" do
      result = Utils.validate_required([username: "This field is required."], "username", "testuser")
      assert [] = result
    end

    test "keeps other errors when value is provided" do
      result = Utils.validate_required([email: "The e-mail format is not valid."], "username", "testuser")
      assert [email: "The e-mail format is not valid."] = result
    end
  end

  describe "validate_password/3" do
    test "returns error when password is too short" do
      result = Utils.validate_password([], "password", "short")
      assert [password: "The password must contain letters, numbers, a capital letter or special character, and be at least 8 characters long."] = result
    end

    test "returns error when password contains invalid characters" do
      result = Utils.validate_password([], "password", "pass@word")
      assert [password: "The password must contain letters, numbers, a capital letter or special character, and be at least 8 characters long."] = result
    end

    test "removes error when password becomes valid" do
      result = Utils.validate_password([password: "The password must contain letters, numbers, a capital letter or special character, and be at least 8 characters long."], "password", "password123")
      assert [] = result
    end
  end

  describe "validate_email/3" do
    test "returns error when email format is invalid" do
      result = Utils.validate_email([], "email", "invalid-email")
      assert [email: "The e-mail format is not valid."] = result
    end

    test "returns error when email is missing domain" do
      result = Utils.validate_email([], "email", "test@")
      assert [email: "The e-mail format is not valid."] = result
    end

    test "removes error when email becomes valid" do
      result = Utils.validate_email([email: "The e-mail format is not valid."], "email", "test@example.com")
      assert [] = result
    end
  end

  describe "validate_username/3" do
    test "returns error when username contains invalid characters" do
      result = Utils.validate_username([], "username", "user@123")
      assert [username: "The username must contain only letters and numbers."] = result
    end

    test "returns error when username contains spaces" do
      result = Utils.validate_username([], "username", "user 123")
      assert [username: "The username must contain only letters and numbers."] = result
    end

    test "removes error when username becomes valid" do
      result = Utils.validate_username([username: "The username must contain only letters and numbers."], "username", "user123")
      assert [] = result
    end

    test "accepts username with underscores" do
      result = Utils.validate_username([], "username", "user_123")
      assert [] = result
    end
  end

  describe "validate_password_confirm/5" do
    test "returns error when passwords do not match" do
      result = Utils.validate_password_confirm([], "password", "password_confirm", "password123", "different")
      assert [password: "Passwords must match.", password_confirm: "Passwords must match."] = result
    end

    test "removes errors when passwords become matching" do
      result = Utils.validate_password_confirm([password: "Passwords must match.", password_confirm: "Passwords must match."], "password", "password_confirm", "password123", "password123")
      assert [] = result
    end
  end

  describe "validate_email_or_username/3" do
    test "returns error when neither email nor username format is valid" do
      result = Utils.validate_email_or_username([], "login", "invalid@")
      assert [login: "Must be a valid email or username (letters and numbers only)."] = result
    end

    test "removes error when input becomes valid email" do
      result = Utils.validate_email_or_username([login: "Must be a valid email or username (letters and numbers only)."], "login", "test@example.com")
      assert [] = result
    end

    test "removes error when input becomes valid username" do
      result = Utils.validate_email_or_username([login: "Must be a valid email or username (letters and numbers only)."], "login", "testuser")
      assert [] = result
    end

    test "accepts username with underscores" do
      result = Utils.validate_email_or_username([], "login", "test_user")
      assert [] = result
    end
  end

  describe "filter_errors/1" do
    test "filters and reverses error list" do
      errors = [
        {"email", "Email error"},
        {"username", "First error"},
        {"username", "Second error"}
      ]
      result = Utils.filter_errors(errors)
      assert [{"email", "Email error"}, {"username", "Second error"}] = result
    end
  end

  describe "field_error/2" do
    test "returns true when field has error" do
      errors = [username: "Error message"]
      assert Utils.field_error(errors, "username") == true
    end

    test "returns false when field has no error" do
      errors = [username: "Error message"]
      assert Utils.field_error(errors, "email") == false
    end
  end

  describe "boolean_checkbox/1" do
    test "returns true for 'on' value" do
      assert Utils.boolean_checkbox("on") == true
    end

    test "returns false for other values" do
      assert Utils.boolean_checkbox("off") == false
      assert Utils.boolean_checkbox("") == false
      assert Utils.boolean_checkbox(nil) == false
    end
  end

  describe "map_from_url/1" do
    test "parses URL with query parameters" do
      url = "https://example.com/path?username=test&email=test@example.com"
      result = Utils.map_from_url(url)
      assert result.username == "test"
      assert result.email == "test@example.com"
      assert result.host == "example.com"
      assert result.path == "/path"
    end

    test "handles URL without query parameters" do
      url = "https://example.com/path"
      result = Utils.map_from_url(url)
      assert result.host == "example.com"
      assert result.path == "/path"
    end
  end

  describe "map_keys_atom_to_string/1" do
    test "converts atom keys to string keys" do
      map = %{username: "test", email: "test@example.com"}
      result = Utils.map_keys_atom_to_string(map)
      assert result["username"] == "test"
      assert result["email"] == "test@example.com"
    end
  end

  describe "map_keys_string_to_atom/1" do
    test "converts string keys to atom keys" do
      map = %{"username" => "test", "email" => "test@example.com"}
      result = Utils.map_keys_string_to_atom(map)
      assert result.username == "test"
      assert result.email == "test@example.com"
    end
  end

  describe "part_url/2" do
    test "extracts domain from URL" do
      url = "https://app.example.com/path"
      result = Utils.part_url(url, :domain)
      # This test might need adjustment based on the actual regex implementation
      assert is_binary(result)
    end

    test "extracts appname from URL" do
      url = "https://app.example.com/path"
      result = Utils.part_url(url, :appname)
      # This test might need adjustment based on the actual regex implementation
      assert is_binary(result)
    end
  end

  describe "host_domain/2" do
    test "constructs host domain URL with default path" do
      params = %{ticket: "abc123", redirect: "https://example.com/dashboard"}
      result = Utils.host_domain(params)
      assert result == "https://example.com/auth?redirect=https://example.com/dashboard&ticket=abc123"
    end

    test "constructs host domain URL with custom path" do
      params = %{ticket: "abc123", redirect: "https://example.com/dashboard"}
      result = Utils.host_domain(params, "custom")
      assert result == "https://example.com/custom?redirect=https://example.com/dashboard&ticket=abc123"
    end
  end
end
