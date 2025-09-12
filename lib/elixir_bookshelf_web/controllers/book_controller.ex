defmodule ElixirBookshelfWeb.BookController do
  use ElixirBookshelfWeb, :controller

  alias ElixirBookshelf.Books

  def index(conn, _params) do
    books = Books.list_books()
    render(conn, :index, books: books)
  end
end
