defmodule ElixirBookshelfWeb.CollectionControllerTest do
  use ElixirBookshelfWeb.ConnCase

  import ElixirBookshelf.Factory
  alias ElixirBookshelf.Collections

  describe "index - authenticated user" do
    test "displays user's collections when user has books", %{conn: conn} do
      user = insert(:user)
      book1 = insert(:book)
      book2 = insert(:book)
      
      {:ok, _collection1} = Collections.create_collection(%{user_id: user.id, book_id: book1.id})
      {:ok, _collection2} = Collections.create_collection(%{user_id: user.id, book_id: book2.id})

      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: user.id})
        |> get(~p"/bookshelf")

      assert html_response(conn, 200) =~ "My Bookshelf"
      assert html_response(conn, 200) =~ book1.title
      assert html_response(conn, 200) =~ book2.title
      assert html_response(conn, 200) =~ "You have 2 books in your collection"
    end

    test "displays user's collection with author information", %{conn: conn} do
      user = insert(:user)
      book = insert(:book)
      
      {:ok, _collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: user.id})
        |> get(~p"/bookshelf")

      assert html_response(conn, 200) =~ book.title
      assert html_response(conn, 200) =~ book.author.first_name
      assert html_response(conn, 200) =~ book.author.last_name
    end

    test "displays formatted word count when present", %{conn: conn} do
      user = insert(:user)
      book = insert(:book, word_count: 123_456)
      
      {:ok, _collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: user.id})
        |> get(~p"/bookshelf")

      assert html_response(conn, 200) =~ "123,456 words"
    end

    test "displays added date for collections", %{conn: conn} do
      user = insert(:user)
      book = insert(:book)
      added_at = DateTime.from_naive!(~N[2024-01-15 10:00:00], "Etc/UTC")
      
      {:ok, _collection} = Collections.create_collection(%{
        user_id: user.id, 
        book_id: book.id, 
        added_at: added_at
      })

      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: user.id})
        |> get(~p"/bookshelf")

      assert html_response(conn, 200) =~ "Added January 15, 2024"
    end

    test "displays empty state when user has no collections", %{conn: conn} do
      user = insert(:user)

      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: user.id})
        |> get(~p"/bookshelf")

      assert html_response(conn, 200) =~ "My Bookshelf"
      assert html_response(conn, 200) =~ "Your bookshelf is empty"
      assert html_response(conn, 200) =~ "Browse Books"
    end

    test "only displays current user's collections, not other users'", %{conn: conn} do
      user1 = insert(:user)
      user2 = insert(:user)
      book1 = insert(:book, title: "User 1 Book")
      book2 = insert(:book, title: "User 2 Book")
      
      {:ok, _collection1} = Collections.create_collection(%{user_id: user1.id, book_id: book1.id})
      {:ok, _collection2} = Collections.create_collection(%{user_id: user2.id, book_id: book2.id})

      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: user1.id})
        |> get(~p"/bookshelf")

      assert html_response(conn, 200) =~ "User 1 Book"
      refute html_response(conn, 200) =~ "User 2 Book"
    end

    test "displays welcome message with user's first name", %{conn: conn} do
      user = insert(:user, first_name: "John", email: "john@example.com")

      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: user.id})
        |> get(~p"/bookshelf")

      assert html_response(conn, 200) =~ "Welcome, John"
    end

    test "displays welcome message with email when no first name", %{conn: conn} do
      user = insert(:user, first_name: nil, email: "john@example.com")

      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: user.id})
        |> get(~p"/bookshelf")

      assert html_response(conn, 200) =~ "Welcome, john@example.com"
    end

    test "includes navigation links", %{conn: conn} do
      user = insert(:user)

      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: user.id})
        |> get(~p"/bookshelf")

      assert html_response(conn, 200) =~ "All Books"
      assert html_response(conn, 200) =~ "Sign Out"
    end

    test "book links navigate to book show page", %{conn: conn} do
      user = insert(:user)
      book = insert(:book)
      
      {:ok, _collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: user.id})
        |> get(~p"/bookshelf")

      assert html_response(conn, 200) =~ ~p"/books/#{book.id}"
    end
  end

  describe "index - unauthenticated user" do
    test "redirects to sign in when user is not authenticated", %{conn: conn} do
      conn = get(conn, ~p"/bookshelf")

      assert redirected_to(conn) == ~p"/session"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You must be logged in to view your bookshelf"
    end

    test "redirects to sign in when user session is invalid", %{conn: conn} do
      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: "nonexistent_user_id"})
        |> get(~p"/bookshelf")

      assert redirected_to(conn) == ~p"/session"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You must be logged in to view your bookshelf"
    end
  end

  describe "route accessibility" do
    test "/bookshelf route is accessible", %{conn: conn} do
      user = insert(:user)
      
      conn = 
        conn
        |> Plug.Test.init_test_session(%{current_user_id: user.id})
        |> get(~p"/bookshelf")

      assert html_response(conn, 200)
    end
  end
end