defmodule ElixirBookshelf.BookTest do
  use ElixirBookshelf.DataCase

  alias ElixirBookshelf.Book
  import ElixirBookshelf.Factory

  describe "changeset/2" do
    test "valid changeset with all fields" do
      changeset =
        Book.changeset(%Book{}, %{
          title: "On Basilisk Station",
          word_count: 12_348
        })

      assert changeset.valid?
      assert changeset.changes.title == "On Basilisk Station"
      assert changeset.changes.word_count == 12_348
    end

    test "valid changeset without word_count" do
      changeset = Book.changeset(%Book{}, %{title: "On Basilisk Station"})

      assert changeset.valid?
      assert changeset.changes == %{title: "On Basilisk Station"}
    end

    test "invalid changeset without title" do
      changeset = Book.changeset(%Book{}, %{})

      refute changeset.valid?
      assert changeset.changes == %{}
    end

    test "ignores invalid fields" do
      changeset = Book.changeset(%Book{}, %{invalid_field: "value", title: "On Basilisk Station"})

      assert changeset.valid?
      refute Map.has_key?(changeset.changes, :invalid_field)
    end
  end

  describe "uxid integration" do
    test "record id includes bk prefix" do
      book = insert(:book)

      returned_book = Repo.get(Book, book.id)
      assert String.contains?(returned_book.id, "bk")
    end
  end
end
