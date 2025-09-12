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

  describe "show" do
    test "displays book details with author", %{conn: conn} do
      book = insert(:book)
      conn = get(conn, ~p"/books/#{book.id}")

      assert html_response(conn, 200) =~ book.title
      assert html_response(conn, 200) =~ book.author.first_name
      assert html_response(conn, 200) =~ book.author.last_name
      assert html_response(conn, 200) =~ "Back to Books"
    end

    test "shows formatted word count when present", %{conn: conn} do
      book = insert(:book, word_count: 123_456)
      conn = get(conn, ~p"/books/#{book.id}")

      assert html_response(conn, 200) =~ "123,456 words"
    end

    test "shows book and author IDs", %{conn: conn} do
      book = insert(:book)
      conn = get(conn, ~p"/books/#{book.id}")

      assert html_response(conn, 200) =~ book.id
      assert html_response(conn, 200) =~ book.author.id
    end

    test "raises 404 when book does not exist", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        get(conn, ~p"/books/nonexistent-id")
      end
    end
  end
end
