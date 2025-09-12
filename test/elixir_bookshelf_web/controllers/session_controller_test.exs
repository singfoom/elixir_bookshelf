defmodule ElixirBookshelfWeb.SessionControllerTest do
  use ElixirBookshelfWeb.ConnCase

  alias ElixirBookshelf.Users

  setup do
    {:ok, user} = Users.create_user(%{
      email: "test@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User"
    })
    
    %{user: user}
  end

  describe "new" do
    test "renders sign in form", %{conn: conn} do
      conn = get(conn, ~p"/session")
      assert html_response(conn, 200) =~ "Sign In"
      assert html_response(conn, 200) =~ "Email"
      assert html_response(conn, 200) =~ "Password"
    end
  end

  describe "create" do
    test "signs in user with valid credentials", %{conn: conn, user: user} do
      session_params = %{
        "email" => user.email,
        "password" => "password123"
      }

      conn = post(conn, ~p"/session", session: session_params)

      assert redirected_to(conn) == ~p"/books"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back"
      assert get_session(conn, :current_user_id) == user.id
    end

    test "renders form with error for invalid credentials", %{conn: conn, user: user} do
      session_params = %{
        "email" => user.email,
        "password" => "wrongpassword"
      }

      conn = post(conn, ~p"/session", session: session_params)

      assert html_response(conn, 200) =~ "Sign In"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Invalid email or password"
      refute get_session(conn, :current_user_id)
    end

    test "renders form with error for non-existent user", %{conn: conn} do
      session_params = %{
        "email" => "nonexistent@example.com",
        "password" => "password123"
      }

      conn = post(conn, ~p"/session", session: session_params)

      assert html_response(conn, 200) =~ "Sign In"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Invalid email or password"
      refute get_session(conn, :current_user_id)
    end
  end

  describe "delete" do
    test "signs out current user", %{conn: conn, user: user} do
      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: user.id})
        |> delete(~p"/session")

      assert redirected_to(conn) == ~p"/books"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "You have been signed out"
      refute get_session(conn, :current_user_id)
    end
  end
end