defmodule ElixirBookshelf.CollectionTest do
  use ElixirBookshelf.DataCase

  alias ElixirBookshelf.Collection
  import ElixirBookshelf.Factory

  describe "changeset/2" do
    test "valid changeset with required fields" do
      user = insert(:user)
      book = insert(:book)
      
      attrs = %{user_id: user.id, book_id: book.id}
      changeset = Collection.changeset(%Collection{}, attrs)

      assert changeset.valid?
      assert changeset.changes.user_id == user.id
      assert changeset.changes.book_id == book.id
      assert changeset.changes.added_at != nil
    end

    test "valid changeset with explicit added_at" do
      user = insert(:user)
      book = insert(:book)
      added_at = DateTime.utc_now() |> DateTime.truncate(:second)
      
      attrs = %{user_id: user.id, book_id: book.id, added_at: added_at}
      changeset = Collection.changeset(%Collection{}, attrs)

      assert changeset.valid?
      assert changeset.changes.added_at == added_at
    end

    test "invalid changeset without user_id" do
      book = insert(:book)
      
      attrs = %{book_id: book.id}
      changeset = Collection.changeset(%Collection{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).user_id
    end

    test "invalid changeset without book_id" do
      user = insert(:user)
      
      attrs = %{user_id: user.id}
      changeset = Collection.changeset(%Collection{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).book_id
    end

    test "database insert fails with non-existent user_id due to foreign key constraint" do
      book = insert(:book)
      
      attrs = %{user_id: "usr_nonexistent", book_id: book.id}
      changeset = Collection.changeset(%Collection{}, attrs)

      # Changeset validation passes - foreign key constraints are checked at database level
      assert changeset.valid?
      
      # Database insert should fail due to foreign key constraint
      {:error, failed_changeset} = Repo.insert(changeset)
      assert "user does not exist" in errors_on(failed_changeset).user_id
    end

    test "database insert fails with non-existent book_id due to foreign key constraint" do
      user = insert(:user)
      
      attrs = %{user_id: user.id, book_id: "bk_nonexistent"}
      changeset = Collection.changeset(%Collection{}, attrs)

      # Changeset validation passes - foreign key constraints are checked at database level  
      assert changeset.valid?
      
      # Database insert should fail due to foreign key constraint
      {:error, failed_changeset} = Repo.insert(changeset)
      assert "book does not exist" in errors_on(failed_changeset).book_id
    end

    test "invalid changeset with duplicate user_id and book_id combination" do
      user = insert(:user)
      book = insert(:book)
      
      # Insert first collection
      attrs = %{user_id: user.id, book_id: book.id}
      changeset = Collection.changeset(%Collection{}, attrs)
      {:ok, _collection} = Repo.insert(changeset)

      # Try to insert duplicate
      duplicate_changeset = Collection.changeset(%Collection{}, attrs)
      {:error, failed_changeset} = Repo.insert(duplicate_changeset)
      
      assert "book already in collection" in errors_on(failed_changeset).user_id
    end
  end

  describe "associations" do
    test "belongs_to user" do
      user = insert(:user)
      book = insert(:book)
      
      attrs = %{user_id: user.id, book_id: book.id}
      {:ok, collection} = 
        %Collection{}
        |> Collection.changeset(attrs)
        |> Repo.insert()

      collection_with_user = Repo.preload(collection, :user)
      assert collection_with_user.user.id == user.id
      assert collection_with_user.user.email == user.email
    end

    test "belongs_to book" do
      user = insert(:user)
      book = insert(:book)
      
      attrs = %{user_id: user.id, book_id: book.id}
      {:ok, collection} = 
        %Collection{}
        |> Collection.changeset(attrs)
        |> Repo.insert()

      collection_with_book = Repo.preload(collection, :book)
      assert collection_with_book.book.id == book.id
      assert collection_with_book.book.title == book.title
    end

    test "preloads both user and book" do
      user = insert(:user)
      book = insert(:book)
      
      attrs = %{user_id: user.id, book_id: book.id}
      {:ok, collection} = 
        %Collection{}
        |> Collection.changeset(attrs)
        |> Repo.insert()

      collection_with_assocs = Repo.preload(collection, [:user, :book])
      assert collection_with_assocs.user.id == user.id
      assert collection_with_assocs.book.id == book.id
    end
  end

  describe "foreign key constraints and cascading deletes" do
    test "collection is deleted when user is deleted (cascade delete)" do
      user = insert(:user)
      book = insert(:book)
      
      attrs = %{user_id: user.id, book_id: book.id}
      {:ok, collection} = 
        %Collection{}
        |> Collection.changeset(attrs)
        |> Repo.insert()

      # Verify collection exists
      assert Repo.get(Collection, collection.id)
      
      # Delete user - this will cascade delete the collection
      Repo.delete!(user)
      
      # Collection should be deleted due to cascade
      refute Repo.get(Collection, collection.id)
    end

    test "collection is deleted when book is deleted (cascade delete)" do
      user = insert(:user)
      # Create a book without an author to avoid foreign key issues
      book = insert(:book, author: nil, author_id: nil)
      
      attrs = %{user_id: user.id, book_id: book.id}
      {:ok, collection} = 
        %Collection{}
        |> Collection.changeset(attrs)
        |> Repo.insert()

      # Verify collection exists
      assert Repo.get(Collection, collection.id)
      
      # Delete book - this will cascade delete the collection
      Repo.delete!(book)
      
      # Collection should be deleted due to cascade
      refute Repo.get(Collection, collection.id)
    end
  end

  describe "timestamps and added_at" do
    test "automatically sets added_at when not provided" do
      user = insert(:user)
      book = insert(:book)
      
      attrs = %{user_id: user.id, book_id: book.id}
      {:ok, collection} = 
        %Collection{}
        |> Collection.changeset(attrs)
        |> Repo.insert()

      assert collection.added_at != nil
      assert collection.inserted_at != nil
      assert collection.updated_at != nil
      
      # added_at should be close to inserted_at
      time_diff = DateTime.diff(collection.inserted_at, collection.added_at, :second)
      assert abs(time_diff) <= 1
    end

    test "respects explicit added_at value" do
      user = insert(:user)
      book = insert(:book)
      explicit_time = DateTime.from_naive!(~N[2024-01-01 10:00:00], "Etc/UTC")
      
      attrs = %{user_id: user.id, book_id: book.id, added_at: explicit_time}
      {:ok, collection} = 
        %Collection{}
        |> Collection.changeset(attrs)
        |> Repo.insert()

      assert collection.added_at == explicit_time
    end
  end
end