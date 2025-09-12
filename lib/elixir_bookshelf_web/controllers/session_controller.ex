defmodule ElixirBookshelfWeb.SessionController do
  use ElixirBookshelfWeb, :controller

  alias ElixirBookshelf.Users

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Users.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "Welcome back, #{user.first_name || user.email}!")
        |> redirect(to: ~p"/books")

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> render(:new)
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "You have been signed out")
    |> redirect(to: ~p"/books")
  end
end