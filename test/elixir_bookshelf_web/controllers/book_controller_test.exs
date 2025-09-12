defmodule ElixirBookshelfWeb.BookControllerTest do
  use ElixirBookshelfWeb.ConnCase

  import ElixirBookshelf.Factory

  describe "index" do
    test "lists all books", %{conn: conn} do
      book = insert(:book)
      conn = get(conn, ~p"/books")
      assert html_response(conn, 200) =~ "Books"
      assert html_response(conn, 200) =~ book.title
    end

    test "shows empty state when no books exist", %{conn: conn} do
      conn = get(conn, ~p"/books")
      assert html_response(conn, 200) =~ "Books"
      assert html_response(conn, 200) =~ "No books found"
    end

    test "GET / redirects to books index", %{conn: conn} do
      book = insert(:book)
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Books"
      assert html_response(conn, 200) =~ book.title
    end
  end
end