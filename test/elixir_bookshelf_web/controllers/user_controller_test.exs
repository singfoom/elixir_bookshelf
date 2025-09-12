defmodule ElixirBookshelfWeb.UserControllerTest do
  use ElixirBookshelfWeb.ConnCase

  alias ElixirBookshelf.Users

  describe "new" do
    test "renders registration form", %{conn: conn} do
      conn = get(conn, ~p"/register")
      assert html_response(conn, 200) =~ "Create Account"
      assert html_response(conn, 200) =~ "Email"
      assert html_response(conn, 200) =~ "Password"
    end
  end

  describe "create" do
    test "creates user with valid attributes and signs them in", %{conn: conn} do
      user_params = %{
        "email" => "test@example.com",
        "password" => "password123",
        "password_confirmation" => "password123",
        "first_name" => "Test",
        "last_name" => "User"
      }

      conn = post(conn, ~p"/register", user: user_params)

      assert redirected_to(conn) == ~p"/books"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Registration successful!"
      
      user = Users.get_user_by_email("test@example.com")
      assert user.first_name == "Test"
      assert user.last_name == "User"
      assert get_session(conn, :current_user_id) == user.id
    end

    test "renders form with errors for invalid attributes", %{conn: conn} do
      user_params = %{
        "email" => "invalid-email",
        "password" => "123",
        "password_confirmation" => "456"
      }

      conn = post(conn, ~p"/register", user: user_params)

      assert html_response(conn, 200) =~ "Create Account"
      assert html_response(conn, 200) =~ "must be a valid email"
      assert html_response(conn, 200) =~ "must be at least 6 characters"
      assert html_response(conn, 200) =~ "does not match password"
    end

    test "renders form with error for duplicate email", %{conn: conn} do
      Users.create_user(%{email: "existing@example.com", password: "password123"})
      
      user_params = %{
        "email" => "existing@example.com",
        "password" => "password123",
        "password_confirmation" => "password123"
      }

      conn = post(conn, ~p"/register", user: user_params)

      assert html_response(conn, 200) =~ "Create Account"
      assert html_response(conn, 200) =~ "email already exists"
    end
  end
end