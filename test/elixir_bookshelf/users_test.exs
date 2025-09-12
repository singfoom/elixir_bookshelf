defmodule ElixirBookshelf.UsersTest do
  use ElixirBookshelf.DataCase

  alias ElixirBookshelf.Users

  describe "list_users/0" do
    test "returns all users" do
      user_1 = insert_user(%{email: "user1@example.com", password: "password123"})
      user_2 = insert_user(%{email: "user2@example.com", password: "password123"})

      users = Users.list_users()

      assert length(users) == 2
      assert Enum.any?(users, fn u -> u.id == user_1.id end)
      assert Enum.any?(users, fn u -> u.id == user_2.id end)
    end

    test "returns empty list when no users exist" do
      users = Users.list_users()
      assert users == []
    end
  end

  describe "get_user/1" do
    test "returns the user when it exists" do
      user = insert_user(%{email: "user@example.com", password: "password123"})

      result = Users.get_user(user.id)

      assert result.id == user.id
      assert result.email == user.email
    end

    test "returns nil when user does not exist" do
      result = Users.get_user("nonexistent-id")
      assert result == nil
    end
  end

  describe "get_user!/1" do
    test "returns the user when it exists" do
      user = insert_user(%{email: "user@example.com", password: "password123"})

      result = Users.get_user!(user.id)

      assert result.id == user.id
      assert result.email == user.email
    end

    test "raises when user does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Users.get_user!("nonexistent-id")
      end
    end
  end

  describe "get_user_by_email/1" do
    test "returns the user when email exists" do
      user = insert_user(%{email: "user@example.com", password: "password123"})

      result = Users.get_user_by_email("user@example.com")

      assert result.id == user.id
      assert result.email == user.email
    end

    test "returns nil when email does not exist" do
      result = Users.get_user_by_email("nonexistent@example.com")
      assert result == nil
    end
  end

  describe "create_user/1" do
    test "creates a user with valid attributes" do
      attrs = %{
        email: "user@example.com",
        password: "password123",
        first_name: "John",
        last_name: "Doe"
      }

      {:ok, user} = Users.create_user(attrs)

      assert user.email == "user@example.com"
      assert user.first_name == "John"
      assert user.last_name == "Doe"
      assert user.password_hash != nil
    end

    test "returns error changeset with invalid attributes" do
      attrs = %{email: "invalid-email", password: "123"}

      {:error, changeset} = Users.create_user(attrs)

      assert changeset.valid? == false
      assert "must be a valid email" in errors_on(changeset).email
      assert "must be at least 6 characters" in errors_on(changeset).password
    end

    test "returns error changeset with duplicate email" do
      insert_user(%{email: "user@example.com", password: "password123"})
      attrs = %{email: "user@example.com", password: "password123"}

      {:error, changeset} = Users.create_user(attrs)

      assert changeset.valid? == false
      assert "email already exists" in errors_on(changeset).email
    end
  end

  describe "register_user/1" do
    test "registers a user with valid attributes" do
      attrs = %{
        email: "user@example.com",
        password: "password123",
        password_confirmation: "password123",
        first_name: "John",
        last_name: "Doe"
      }

      {:ok, user} = Users.register_user(attrs)

      assert user.email == "user@example.com"
      assert user.first_name == "John"
      assert user.last_name == "Doe"
      assert user.password_hash != nil
    end

    test "returns error changeset without password confirmation" do
      attrs = %{
        email: "user@example.com",
        password: "password123"
      }

      {:error, changeset} = Users.register_user(attrs)

      assert changeset.valid? == false
      assert "can't be blank" in errors_on(changeset).password_confirmation
    end
  end

  describe "update_user/2" do
    test "updates user with valid attributes" do
      user = insert_user(%{email: "original@example.com", password: "password123"})
      attrs = %{first_name: "Updated", last_name: "Name"}

      {:ok, updated_user} = Users.update_user(user, attrs)

      assert updated_user.first_name == "Updated"
      assert updated_user.last_name == "Name"
      assert updated_user.email == "original@example.com"
    end

    test "returns error changeset with invalid attributes" do
      user = insert_user(%{email: "user@example.com", password: "password123"})
      attrs = %{email: "invalid-email"}

      {:error, changeset} = Users.update_user(user, attrs)

      assert changeset.valid? == false
      assert "must be a valid email" in errors_on(changeset).email
    end
  end

  describe "delete_user/1" do
    test "deletes the user" do
      user = insert_user(%{email: "user@example.com", password: "password123"})

      {:ok, deleted_user} = Users.delete_user(user)

      assert deleted_user.id == user.id
      assert Users.get_user(user.id) == nil
    end
  end

  describe "authenticate_user/2" do
    test "returns {:ok, user} with valid credentials" do
      insert_user(%{email: "user@example.com", password: "password123"})

      {:ok, user} = Users.authenticate_user("user@example.com", "password123")

      assert user.email == "user@example.com"
    end

    test "returns {:error, :invalid_credentials} with wrong password" do
      insert_user(%{email: "user@example.com", password: "password123"})

      result = Users.authenticate_user("user@example.com", "wrongpassword")

      assert result == {:error, :invalid_credentials}
    end

    test "returns {:error, :invalid_credentials} with non-existent email" do
      result = Users.authenticate_user("nonexistent@example.com", "password123")

      assert result == {:error, :invalid_credentials}
    end
  end

  # Helper function to insert a user
  defp insert_user(attrs) do
    {:ok, user} = Users.create_user(attrs)
    user
  end
end