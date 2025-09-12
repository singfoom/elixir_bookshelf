defmodule ElixirBookshelfWeb.PageControllerTest do
  use ElixirBookshelfWeb.ConnCase

  import ElixirBookshelf.Factory

  test "GET / redirects to books index", %{conn: conn} do
    book = insert(:book)
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Books"
    assert html_response(conn, 200) =~ book.title
  end
end
