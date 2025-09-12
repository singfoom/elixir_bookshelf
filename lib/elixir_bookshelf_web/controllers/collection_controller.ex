defmodule ElixirBookshelfWeb.CollectionController do
  use ElixirBookshelfWeb, :controller

  alias ElixirBookshelf.Collections

  def index(conn, _params) do
    current_user = conn.assigns.current_user

    if current_user do
      collections = Collections.list_collections_by_user(current_user.id)
      render(conn, :index, collections: collections)
    else
      conn
      |> put_flash(:error, "You must be logged in to view your bookshelf")
      |> redirect(to: ~p"/session")
    end
  end
end