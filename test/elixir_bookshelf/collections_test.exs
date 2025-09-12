defmodule ElixirBookshelf.CollectionsTest do
  use ElixirBookshelf.DataCase

  alias ElixirBookshelf.Collections
  import ElixirBookshelf.Factory

  describe "list_collections/0" do
    test "returns all collections with preloaded associations" do
      user = insert(:user)
      book = insert(:book)
      {:ok, collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      collections = Collections.list_collections()

      assert length(collections) == 1
      [returned_collection] = collections
      assert returned_collection.id == collection.id
      assert returned_collection.user.id == user.id
      assert returned_collection.book.id == book.id
    end

    test "returns empty list when no collections exist" do
      assert Collections.list_collections() == []
    end
  end

  describe "get_collection/1" do
    test "returns collection with preloaded associations when found" do
      user = insert(:user)
      book = insert(:book)
      {:ok, collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      returned_collection = Collections.get_collection(collection.id)

      assert returned_collection.id == collection.id
      assert returned_collection.user.id == user.id
      assert returned_collection.book.id == book.id
    end

    test "returns nil when collection not found" do
      assert Collections.get_collection("col_nonexistent") == nil
    end
  end

  describe "get_collection!/1" do
    test "returns collection with preloaded associations when found" do
      user = insert(:user)
      book = insert(:book)
      {:ok, collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      returned_collection = Collections.get_collection!(collection.id)

      assert returned_collection.id == collection.id
      assert returned_collection.user.id == user.id
      assert returned_collection.book.id == book.id
    end

    test "raises Ecto.NoResultsError when collection not found" do
      assert_raise Ecto.NoResultsError, fn ->
        Collections.get_collection!("col_nonexistent")
      end
    end
  end

  describe "create_collection/1" do
    test "creates collection with valid attributes" do
      user = insert(:user)
      book = insert(:book)
      attrs = %{user_id: user.id, book_id: book.id}

      {:ok, collection} = Collections.create_collection(attrs)

      assert collection.user_id == user.id
      assert collection.book_id == book.id
      assert collection.added_at != nil
    end

    test "returns error changeset with invalid attributes" do
      {:error, changeset} = Collections.create_collection(%{})

      assert "can't be blank" in errors_on(changeset).user_id
      assert "can't be blank" in errors_on(changeset).book_id
    end

    test "returns error changeset when user does not exist" do
      book = insert(:book)
      attrs = %{user_id: "usr_nonexistent", book_id: book.id}

      {:error, changeset} = Collections.create_collection(attrs)

      assert "user does not exist" in errors_on(changeset).user_id
    end

    test "returns error changeset when book does not exist" do
      user = insert(:user)
      attrs = %{user_id: user.id, book_id: "bk_nonexistent"}

      {:error, changeset} = Collections.create_collection(attrs)

      assert "book does not exist" in errors_on(changeset).book_id
    end

    test "returns error changeset when user already has book in collection" do
      user = insert(:user)
      book = insert(:book)
      attrs = %{user_id: user.id, book_id: book.id}

      {:ok, _collection} = Collections.create_collection(attrs)
      {:error, changeset} = Collections.create_collection(attrs)

      assert "book already in collection" in errors_on(changeset).user_id
    end
  end

  describe "update_collection/2" do
    test "updates collection with valid attributes" do
      user = insert(:user)
      book = insert(:book)
      {:ok, collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      new_time = DateTime.from_naive!(~N[2024-01-01 10:00:00], "Etc/UTC")
      {:ok, updated_collection} = Collections.update_collection(collection, %{added_at: new_time})

      assert updated_collection.added_at == new_time
    end

    test "returns error changeset with invalid attributes" do
      user = insert(:user)
      book = insert(:book)
      {:ok, collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      {:error, changeset} = Collections.update_collection(collection, %{user_id: nil})

      assert "can't be blank" in errors_on(changeset).user_id
    end
  end

  describe "delete_collection/1" do
    test "deletes the collection" do
      user = insert(:user)
      book = insert(:book)
      {:ok, collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      {:ok, deleted_collection} = Collections.delete_collection(collection)

      assert deleted_collection.id == collection.id
      assert Collections.get_collection(collection.id) == nil
    end
  end

  describe "list_collections_by_user/1" do
    test "returns all collections for a specific user with preloaded associations" do
      user1 = insert(:user)
      user2 = insert(:user)
      book1 = insert(:book)
      book2 = insert(:book)
      book3 = insert(:book)

      {:ok, collection1} = Collections.create_collection(%{user_id: user1.id, book_id: book1.id})
      {:ok, collection2} = Collections.create_collection(%{user_id: user1.id, book_id: book2.id})
      {:ok, _collection3} = Collections.create_collection(%{user_id: user2.id, book_id: book3.id})

      user1_collections = Collections.list_collections_by_user(user1.id)

      assert length(user1_collections) == 2
      collection_ids = Enum.map(user1_collections, & &1.id)
      assert collection1.id in collection_ids
      assert collection2.id in collection_ids

      [first_collection | _] = user1_collections
      assert first_collection.user.id == user1.id
      assert first_collection.book != nil
    end

    test "returns empty list when user has no collections" do
      user = insert(:user)

      assert Collections.list_collections_by_user(user.id) == []
    end

    test "returns empty list when user does not exist" do
      assert Collections.list_collections_by_user("usr_nonexistent") == []
    end
  end

  describe "get_collection_by_user_and_book/2" do
    test "returns collection when user has the book with preloaded associations" do
      user = insert(:user)
      book = insert(:book)
      {:ok, collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      returned_collection = Collections.get_collection_by_user_and_book(user.id, book.id)

      assert returned_collection.id == collection.id
      assert returned_collection.user.id == user.id
      assert returned_collection.book.id == book.id
    end

    test "returns nil when user does not have the book" do
      user = insert(:user)
      book = insert(:book)

      assert Collections.get_collection_by_user_and_book(user.id, book.id) == nil
    end

    test "returns nil when user does not exist" do
      book = insert(:book)

      assert Collections.get_collection_by_user_and_book("usr_nonexistent", book.id) == nil
    end

    test "returns nil when book does not exist" do
      user = insert(:user)

      assert Collections.get_collection_by_user_and_book(user.id, "bk_nonexistent") == nil
    end
  end

  describe "user_has_book?/2" do
    test "returns true when user has book in collection" do
      user = insert(:user)
      book = insert(:book)
      {:ok, _collection} = Collections.create_collection(%{user_id: user.id, book_id: book.id})

      assert Collections.user_has_book?(user.id, book.id) == true
    end

    test "returns false when user does not have book in collection" do
      user = insert(:user)
      book = insert(:book)

      assert Collections.user_has_book?(user.id, book.id) == false
    end

    test "returns false when user does not exist" do
      book = insert(:book)

      assert Collections.user_has_book?("usr_nonexistent", book.id) == false
    end

    test "returns false when book does not exist" do
      user = insert(:user)

      assert Collections.user_has_book?(user.id, "bk_nonexistent") == false
    end
  end

  describe "add_book_to_user_collection/2" do
    test "adds book to user collection successfully" do
      user = insert(:user)
      book = insert(:book)

      {:ok, collection} = Collections.add_book_to_user_collection(user.id, book.id)

      assert collection.user_id == user.id
      assert collection.book_id == book.id
      assert Collections.user_has_book?(user.id, book.id) == true
    end

    test "returns error when user does not exist" do
      book = insert(:book)

      {:error, changeset} = Collections.add_book_to_user_collection("usr_nonexistent", book.id)

      assert "user does not exist" in errors_on(changeset).user_id
    end

    test "returns error when book does not exist" do
      user = insert(:user)

      {:error, changeset} = Collections.add_book_to_user_collection(user.id, "bk_nonexistent")

      assert "book does not exist" in errors_on(changeset).book_id
    end

    test "returns error when book already in user collection" do
      user = insert(:user)
      book = insert(:book)
      {:ok, _collection} = Collections.add_book_to_user_collection(user.id, book.id)

      {:error, changeset} = Collections.add_book_to_user_collection(user.id, book.id)

      assert "book already in collection" in errors_on(changeset).user_id
    end
  end

  describe "remove_book_from_user_collection/2" do
    test "removes book from user collection successfully" do
      user = insert(:user)
      book = insert(:book)
      {:ok, collection} = Collections.add_book_to_user_collection(user.id, book.id)

      {:ok, deleted_collection} = Collections.remove_book_from_user_collection(user.id, book.id)

      assert deleted_collection.id == collection.id
      assert Collections.user_has_book?(user.id, book.id) == false
    end

    test "returns error when collection does not exist" do
      user = insert(:user)
      book = insert(:book)

      {:error, :not_found} = Collections.remove_book_from_user_collection(user.id, book.id)
    end

    test "returns error when user does not exist" do
      book = insert(:book)

      {:error, :not_found} = Collections.remove_book_from_user_collection("usr_nonexistent", book.id)
    end

    test "returns error when book does not exist" do
      user = insert(:user)

      {:error, :not_found} = Collections.remove_book_from_user_collection(user.id, "bk_nonexistent")
    end
  end
end