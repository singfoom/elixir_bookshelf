defmodule ElixirBookshelfWeb.CollectionLive do
  use ElixirBookshelfWeb, :live_view

  alias ElixirBookshelf.{Collections, Books}

  def mount(_params, session, socket) do
    current_user_id = session["current_user_id"]

    if current_user = current_user_id && ElixirBookshelf.Users.get_user(current_user_id) do
      collections = Collections.list_collections_by_user(current_user.id)
      available_books = Books.list_books()
      
      # Filter out books that are already in the user's collection
      collection_book_ids = collections |> Enum.map(& &1.book_id) |> MapSet.new()
      available_books = Enum.reject(available_books, &MapSet.member?(collection_book_ids, &1.id))

      {:ok, 
       socket
       |> assign(:current_user, current_user)
       |> assign(:collections, collections)
       |> assign(:available_books, available_books)
       |> assign(:show_add_books, false)}
    else
      {:ok, 
       socket
       |> put_flash(:error, "You must be logged in to view your bookshelf")
       |> redirect(to: ~p"/session")}
    end
  end

  def handle_event("toggle_add_books", _params, socket) do
    {:noreply, assign(socket, :show_add_books, !socket.assigns.show_add_books)}
  end

  def handle_event("add_book", %{"book_id" => book_id}, socket) do
    current_user = socket.assigns.current_user

    case Collections.add_book_to_user_collection(current_user.id, book_id) do
      {:ok, _collection} ->
        # Reload collections and available books
        collections = Collections.list_collections_by_user(current_user.id)
        available_books = Books.list_books()
        
        # Filter out books that are already in the user's collection
        collection_book_ids = collections |> Enum.map(& &1.book_id) |> MapSet.new()
        available_books = Enum.reject(available_books, &MapSet.member?(collection_book_ids, &1.id))

        # Find the book that was added for the flash message
        added_book = Enum.find(collections, &(&1.book_id == book_id))
        book_title = if added_book, do: added_book.book.title, else: "Book"

        {:noreply,
         socket
         |> assign(:collections, collections)
         |> assign(:available_books, available_books)
         |> put_flash(:info, "#{book_title} has been added to your bookshelf!")}

      {:error, changeset} ->
        error_message = 
          case changeset.errors do
            [user_id: {"book already in collection", _}] -> "This book is already in your collection"
            [user_id: {"user does not exist", _}] -> "User not found"
            [book_id: {"book does not exist", _}] -> "Book not found"
            _ -> "Unable to add book to your collection"
          end

        {:noreply, put_flash(socket, :error, error_message)}
    end
  end

  def handle_event("remove_book", %{"book_id" => book_id}, socket) do
    current_user = socket.assigns.current_user

    case Collections.remove_book_from_user_collection(current_user.id, book_id) do
      {:ok, deleted_collection} ->
        # Reload collections and available books
        collections = Collections.list_collections_by_user(current_user.id)
        available_books = Books.list_books()
        
        # Filter out books that are already in the user's collection
        collection_book_ids = collections |> Enum.map(& &1.book_id) |> MapSet.new()
        available_books = Enum.reject(available_books, &MapSet.member?(collection_book_ids, &1.id))

        book_title = 
          case deleted_collection.book do
            %{title: title} -> title
            _ -> "Book"
          end

        {:noreply,
         socket
         |> assign(:collections, collections)
         |> assign(:available_books, available_books)
         |> put_flash(:info, "#{book_title} has been removed from your bookshelf")}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Book not found in your collection")}
    end
  end
end