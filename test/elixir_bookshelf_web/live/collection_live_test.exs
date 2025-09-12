defmodule ElixirBookshelfWeb.CollectionLiveTest do
  use ElixirBookshelfWeb.ConnCase

  import Phoenix.LiveViewTest
  import ElixirBookshelf.Factory
  alias ElixirBookshelf.Collections

  describe "mount - authenticated user" do
    test "displays user's collections when user has books", %{conn: conn} do
      user = insert(:user)
      book1 = insert(:book)
      book2 = insert(:book)
      
      {:ok, _collection1} = Collections.create_collection(%{user_id: user.id, book_id: book1.id})
      {:ok, _collection2} = Collections.create_collection(%{user_id: user.id, book_id: book2.id})

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, _view, html} = live(conn, ~p"/bookshelf", on_error: :warn)

      assert html =~ "My Bookshelf"
      assert html =~ book1.title
      assert html =~ book2.title
      assert html =~ "You have 2 books in your collection"
    end

    test "displays user's collection with author information", %{conn: conn} do
      user = insert(:user)
      book = insert(:book)
      
      {:ok, _collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, _view, html} = live(conn, ~p"/bookshelf", on_error: :warn)

      assert html =~ book.title
      assert html =~ book.author.first_name
      assert html =~ book.author.last_name
    end

    test "displays formatted word count when present", %{conn: conn} do
      user = insert(:user)
      book = insert(:book, word_count: 123_456)
      
      {:ok, _collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, _view, html} = live(conn, ~p"/bookshelf", on_error: :warn)

      assert html =~ "123,456 words"
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

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, _view, html} = live(conn, ~p"/bookshelf", on_error: :warn)

      assert html =~ "Added January 15, 2024"
    end

    test "displays empty state when user has no collections", %{conn: conn} do
      user = insert(:user)

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, _view, html} = live(conn, ~p"/bookshelf", on_error: :warn)

      assert html =~ "My Bookshelf"
      assert html =~ "Your bookshelf is empty"
      assert html =~ "Add Books to Bookshelf"
    end

    test "only displays current user's collections, not other users'", %{conn: conn} do
      user1 = insert(:user)
      user2 = insert(:user)
      book1 = insert(:book, title: "User 1 Book")
      book2 = insert(:book, title: "User 2 Book")
      
      {:ok, _collection1} = Collections.create_collection(%{user_id: user1.id, book_id: book1.id})
      {:ok, _collection2} = Collections.create_collection(%{user_id: user2.id, book_id: book2.id})

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user1.id})
      
      {:ok, _view, html} = live(conn, ~p"/bookshelf", on_error: :warn)

      assert html =~ "User 1 Book"
      refute html =~ "User 2 Book"
    end

    test "displays welcome message with user's first name", %{conn: conn} do
      user = insert(:user, first_name: "John", email: "john@example.com")

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, _view, html} = live(conn, ~p"/bookshelf", on_error: :warn)

      assert html =~ "Welcome, John"
    end

    test "displays welcome message with email when no first name", %{conn: conn} do
      user = insert(:user, first_name: nil, email: "john@example.com")

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, _view, html} = live(conn, ~p"/bookshelf", on_error: :warn)

      assert html =~ "Welcome, john@example.com"
    end

    test "includes navigation links", %{conn: conn} do
      user = insert(:user)

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, _view, html} = live(conn, ~p"/bookshelf", on_error: :warn)

      assert html =~ "All Books"
      assert html =~ "Sign Out"
    end

    test "book links navigate to book show page", %{conn: conn} do
      user = insert(:user)
      book = insert(:book)
      
      {:ok, _collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, _view, html} = live(conn, ~p"/bookshelf", on_error: :warn)

      assert html =~ ~p"/books/#{book.id}"
    end

    test "shows available books when not in user's collection", %{conn: conn} do
      user = insert(:user)
      book1 = insert(:book, title: "In Collection")
      book2 = insert(:book, title: "Available Book")
      
      # Add only book1 to user's collection
      {:ok, _collection} = Collections.create_collection(%{user_id: user.id, book_id: book1.id})

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, view, _html} = live(conn, ~p"/bookshelf", on_error: :warn)

      # Initially, available books section should be hidden
      refute has_element?(view, "button[phx-click='add_book'][phx-value-book_id='#{book2.id}']")
      
      # Click to show available books
      view |> element("button", "Add Books to Bookshelf") |> render_click()
      
      # Now available book should be visible in available books section (Add button)
      assert has_element?(view, "button[phx-click='add_book'][phx-value-book_id='#{book2.id}']")
      # The available book should appear in rendered content
      assert render(view) =~ "Available Book"
      # The book in collection should not appear in available books section (no Add button)
      refute has_element?(view, "button[phx-click='add_book'][phx-value-book_id='#{book1.id}']")
    end
  end

  describe "mount - unauthenticated user" do
    test "redirects to sign in when user is not authenticated", %{conn: conn} do
      {:error, {:redirect, %{to: "/session"}}} = live(conn, ~p"/bookshelf")
    end

    test "redirects to sign in when user session is invalid", %{conn: conn} do
      conn = Plug.Test.init_test_session(conn, %{current_user_id: "nonexistent_user_id"})
      
      {:error, {:redirect, %{to: "/session"}}} = live(conn, ~p"/bookshelf")
    end
  end

  describe "toggle_add_books event" do
    test "toggles visibility of available books section", %{conn: conn} do
      user = insert(:user)
      _available_book = insert(:book, title: "Available Book")

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, view, _html} = live(conn, ~p"/bookshelf", on_error: :warn)

      # Initially, available books section should not be visible (no Add buttons)
      refute has_element?(view, "button[phx-click='add_book']")
      
      # Click to show available books
      html = view |> element("button", "Add Books to Bookshelf") |> render_click()
      assert html =~ "Available Book"
      assert html =~ "Available Books"
      assert has_element?(view, "button[phx-click='add_book']")
      
      # Click again to hide
      view |> element("button", "Hide Available Books") |> render_click()
      refute has_element?(view, "button[phx-click='add_book']")
    end
  end

  describe "add_book event" do
    test "successfully adds book to user's collection", %{conn: conn} do
      user = insert(:user)
      book = insert(:book, title: "New Book")

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, view, _html} = live(conn, ~p"/bookshelf", on_error: :warn)

      # Show available books
      view |> element("button", "Add Books to Bookshelf") |> render_click()
      
      # Add the book
      html = view |> element("button[phx-value-book_id='#{book.id}']", "Add") |> render_click()
      
      # Should show success message and book should be in collection
      assert html =~ "New Book has been added to your bookshelf!"
      assert html =~ "New Book" # Should now appear in collections section
      assert html =~ "You have 1 book in your collection"
    end

    test "shows error when trying to add book already in collection", %{conn: conn} do
      user = insert(:user)
      book = insert(:book, title: "Existing Book")
      
      # Add book to collection first
      {:ok, _collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, view, _html} = live(conn, ~p"/bookshelf", on_error: :warn)

      # The book should not appear in available books since it's already in collection
      view |> element("button", "Add Books to Bookshelf") |> render_click()
      # Check specifically for Add buttons (available books), not Remove buttons (collections)
      refute has_element?(view, "button[phx-click='add_book'][phx-value-book_id='#{book.id}']")
    end

    test "shows error when book does not exist", %{conn: conn} do
      user = insert(:user)

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, view, _html} = live(conn, ~p"/bookshelf", on_error: :warn)

      # Try to add non-existent book
      html = render_click(view, "add_book", %{"book_id" => "nonexistent_book_id"})
      
      assert html =~ "Book not found"
    end
  end

  describe "remove_book event" do
    test "successfully removes book from user's collection", %{conn: conn} do
      user = insert(:user)
      book = insert(:book, title: "Book to Remove")
      
      {:ok, _collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, view, html} = live(conn, ~p"/bookshelf", on_error: :warn)

      # Should show the book initially
      assert html =~ "Book to Remove"
      assert html =~ "You have 1 book in your collection"
      
      # Remove the book
      html = view |> element("button[phx-value-book_id='#{book.id}']", "Remove") |> render_click()
      
      # Should show success message and empty state
      assert html =~ "Book to Remove has been removed from your bookshelf"
      assert html =~ "Your bookshelf is empty"
    end

    test "shows error when trying to remove book not in collection", %{conn: conn} do
      user = insert(:user)
      book = insert(:book)

      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, view, _html} = live(conn, ~p"/bookshelf", on_error: :warn)

      # Try to remove book that's not in collection
      html = render_click(view, "remove_book", %{"book_id" => book.id})
      
      assert html =~ "Book not found in your collection"
    end
  end

  describe "route accessibility" do
    test "/bookshelf live route is accessible", %{conn: conn} do
      user = insert(:user)
      
      conn = Plug.Test.init_test_session(conn, %{current_user_id: user.id})
      
      {:ok, _view, html} = live(conn, ~p"/bookshelf", on_error: :warn)

      assert html =~ "My Bookshelf"
    end
  end
end