defmodule ElixirBookshelfWeb.UserController do
  use ElixirBookshelfWeb, :controller

  alias ElixirBookshelf.{Users, User}

  def new(conn, _params) do
    changeset = Users.change_user(%User{}, %{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Users.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "Registration successful! Welcome, #{user.first_name || user.email}!")
        |> redirect(to: ~p"/books")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end