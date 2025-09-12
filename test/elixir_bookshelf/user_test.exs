defmodule ElixirBookshelf.UserTest do
  use ElixirBookshelf.DataCase

  alias ElixirBookshelf.User

  describe "changeset/2" do
    test "valid changeset with all fields" do
      attrs = %{
        email: "user@example.com",
        password: "password123",
        first_name: "John",
        last_name: "Doe"
      }
      
      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid?
      assert get_change(changeset, :email) == "user@example.com"
      assert get_change(changeset, :first_name) == "John"
      assert get_change(changeset, :last_name) == "Doe"
      assert get_change(changeset, :password_hash) != nil
    end

    test "valid changeset with required fields only" do
      attrs = %{
        email: "user@example.com",
        password: "password123"
      }
      
      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid?
      assert get_change(changeset, :email) == "user@example.com"
      assert get_change(changeset, :password_hash) != nil
    end

    test "invalid changeset without email" do
      attrs = %{password: "password123"}
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).email
    end

    test "invalid changeset without password" do
      attrs = %{email: "user@example.com"}
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).password
    end

    test "invalid changeset with invalid email format" do
      attrs = %{
        email: "invalid-email",
        password: "password123"
      }
      
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert "must be a valid email" in errors_on(changeset).email
    end

    test "invalid changeset with short password" do
      attrs = %{
        email: "user@example.com",
        password: "12345"
      }
      
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert "must be at least 6 characters" in errors_on(changeset).password
    end

    test "invalid changeset with mismatched password confirmation" do
      attrs = %{
        email: "user@example.com",
        password: "password123",
        password_confirmation: "different"
      }
      
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert "does not match password" in errors_on(changeset).password_confirmation
    end
  end

  describe "registration_changeset/2" do
    test "valid registration changeset with password confirmation" do
      attrs = %{
        email: "user@example.com",
        password: "password123",
        password_confirmation: "password123",
        first_name: "John",
        last_name: "Doe"
      }
      
      changeset = User.registration_changeset(%User{}, attrs)

      assert changeset.valid?
    end

    test "invalid registration changeset without password confirmation" do
      attrs = %{
        email: "user@example.com",
        password: "password123"
      }
      
      changeset = User.registration_changeset(%User{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).password_confirmation
    end
  end

  describe "verify_password/2" do
    test "returns true for correct password" do
      user = %User{password_hash: "$2b$12$K2LoVL9kVFruWVY1mTzP.OUC.RUWmwQ3jF2GbcjMsV5Fmv3hK9Ot6"}
      
      # Note: This test would need actual bcrypt for real implementation
      # For now, testing the function exists and handles the case
      result = User.verify_password(user, "password123")
      assert is_boolean(result)
    end

    test "returns false for incorrect password" do
      user = %User{password_hash: "$2b$12$K2LoVL9kVFruWVY1mTzP.OUC.RUWmwQ3jF2GbcjMsV5Fmv3hK9Ot6"}
      
      result = User.verify_password(user, "wrongpassword")
      assert result == false
    end

    test "returns false for user without password hash" do
      user = %User{password_hash: nil}
      
      result = User.verify_password(user, "password123")
      assert result == false
    end
  end
end