defmodule JwtAuthProject.AccountsTest do
  use ExUnit.Case
  alias JwtAuthProject.Accounts

  describe "user management" do
    test "create_user_with_password/1 function exists" do
      assert is_function(&Accounts.create_user_with_password/1)
    end

    test "get_user_by_username_and_password/2 function exists" do
      assert is_function(&Accounts.get_user_by_username_and_password/2)
    end

    test "get_user_by_email_or_username_and_password/2 function exists" do
      assert is_function(&Accounts.get_user_by_email_or_username_and_password/2)
    end

    test "user_blacklisted?/1 function exists" do
      assert is_function(&Accounts.user_blacklisted?/1)
    end

    test "create_role/1 function exists" do
      assert is_function(&Accounts.create_role/1)
    end

    test "create_user_blacklist/1 function exists" do
      assert is_function(&Accounts.create_user_blacklist/1)
    end
  end
end
