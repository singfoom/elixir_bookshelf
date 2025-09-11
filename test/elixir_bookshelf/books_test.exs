defmodule ElixirBookshelf.BooksTest do
  use ElixirBookshelf.DataCase

  alias ElixirBookshelf.Books
  import ElixirBookshelf.Factory

  describe "list_books/0" do
    test "returns all books" do
      book_1 = insert(:book)
      book_2 = insert(:book)

      books = Books.list_books()

      assert length(books) == 2
      assert Enum.any?(books, fn c -> c.id == book_1.id end)
      assert Enum.any?(books, fn c -> c.id == book_2.id end)
    end

    test "returns empty list when no books exist" do
      books = Books.list_books()
      assert books == []
    end
  end

  describe "get_book/1" do
    test "returns the book when it exists" do
      book = insert(:book)

      result = Books.get_book(book.id)

      assert result.id == book.id
      assert result.title == book.title
    end

    test "returns nil when book does not exist" do
      result = Books.get_book("nonexistent-id")
      assert result == nil
    end
  end

  describe "get_book!/1" do
    test "returns the book when it exists" do
      book = insert(:book)

      result = Books.get_book!(book.id)

      assert result.id == book.id
      assert result.title == book.title
    end

    test "raises when book does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Books.get_book!("nonexistent-id")
      end
    end
  end

  describe "create_book/1" do
    test "creates a book with valid attributes" do
      attrs = %{title: "Test Book", word_count: 50_000}

      {:ok, book} = Books.create_book(attrs)

      assert book.title == "Test Book"
      assert book.word_count == 50_000
    end

    test "returns error changeset with invalid attributes" do
      attrs = %{title: "", word_count: -1}

      {:error, changeset} = Books.create_book(attrs)

      assert changeset.valid? == false
      assert "can't be blank" in errors_on(changeset).title
    end

    test "empty attrs returns a error changeset tuple" do
      {:error, changeset} = Books.create_book()

      assert changeset.valid? == false
    end
  end

  describe "update_book/2" do
    test "updates book with valid attributes" do
      book = insert(:book, title: "Original Title")
      attrs = %{title: "Updated Title", word_count: 75_000}

      {:ok, updated_book} = Books.update_book(book, attrs)

      assert updated_book.title == "Updated Title"
      assert updated_book.word_count == 75_000
    end

    test "returns error changeset with invalid attributes" do
      book = insert(:book)
      attrs = %{title: "", word_count: -1}

      {:error, changeset} = Books.update_book(book, attrs)

      assert changeset.valid? == false
      assert "can't be blank" in errors_on(changeset).title
    end
  end

  describe "delete_book/1" do
    test "deletes the book" do
      book = insert(:book)

      {:ok, deleted_book} = Books.delete_book(book)

      assert deleted_book.id == book.id
      assert Books.get_book(book.id) == nil
    end
  end
end
