defmodule ElixirBookshelf.AuthorsTest do
  use ElixirBookshelf.DataCase

  alias ElixirBookshelf.Authors
  import ElixirBookshelf.Factory

  describe "list_authors/0" do
    test "returns all authors" do
      author_1 = insert(:author)
      author_2 = insert(:author)

      authors = Authors.list_authors()

      assert length(authors) == 2
      assert Enum.any?(authors, fn c -> c.id == author_1.id end)
      assert Enum.any?(authors, fn c -> c.id == author_2.id end)
    end

    test "returns empty list when no authors exist" do
      authors = Authors.list_authors()
      assert authors == []
    end
  end

  describe "get_author/1" do
    test "returns the author when it exists" do
      author = insert(:author)

      result = Authors.get_author(author.id)

      assert result.id == author.id
      assert result.first_name == author.first_name
      assert result.last_name == author.last_name
    end

    test "returns nil when author does not exist" do
      result = Authors.get_author("nonexistent-id")
      assert result == nil
    end
  end

  describe "get_author!/1" do
    test "returns the author when it exists" do
      author = insert(:author)

      result = Authors.get_author!(author.id)

      assert result.id == author.id
      assert result.first_name == author.first_name
      assert result.last_name == author.last_name
    end

    test "raises when author does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Authors.get_author!("nonexistent-id")
      end
    end
  end

  describe "create_author/1" do
    test "creates an author with valid attributes" do
      attrs = %{first_name: "Test", last_name: "Author"}

      {:ok, author} = Authors.create_author(attrs)

      assert author.first_name == "Test"
      assert author.last_name == "Author"
    end

    test "returns error changeset with invalid attributes" do
      attrs = %{first_name: "", last_name: ""}

      {:error, changeset} = Authors.create_author(attrs)

      assert changeset.valid? == false
      assert "can't be blank" in errors_on(changeset).first_name
      assert "can't be blank" in errors_on(changeset).last_name
    end

    test "empty attrs returns a error changeset tuple" do
      {:error, changeset} = Authors.create_author()

      assert changeset.valid? == false
    end
  end

  describe "update_author/2" do
    test "updates author with valid attributes" do
      author = insert(:author, first_name: "Original", last_name: "Name")
      attrs = %{first_name: "Updated", last_name: "Author"}

      {:ok, updated_author} = Authors.update_author(author, attrs)

      assert updated_author.first_name == "Updated"
      assert updated_author.last_name == "Author"
    end

    test "returns error changeset with invalid attributes" do
      author = insert(:author)
      attrs = %{first_name: "", last_name: ""}

      {:error, changeset} = Authors.update_author(author, attrs)

      assert changeset.valid? == false
      assert "can't be blank" in errors_on(changeset).first_name
      assert "can't be blank" in errors_on(changeset).last_name
    end
  end

  describe "delete_author/1" do
    test "deletes the author" do
      author = insert(:author)

      {:ok, deleted_author} = Authors.delete_author(author)

      assert deleted_author.id == author.id
      assert Authors.get_author(author.id) == nil
    end
  end
end