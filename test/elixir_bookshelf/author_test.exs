defmodule ElixirBookshelf.AuthorTest do
  use ElixirBookshelf.DataCase

  alias ElixirBookshelf.Author

  describe "changeset/2" do
    test "valid changeset with valid attributes" do
      attrs = %{first_name: "Jane", last_name: "Doe"}
      changeset = Author.changeset(%Author{}, attrs)

      assert changeset.valid?
      assert get_change(changeset, :first_name) == "Jane"
      assert get_change(changeset, :last_name) == "Doe"
    end

    test "invalid changeset with missing first_name" do
      attrs = %{last_name: "Doe"}
      changeset = Author.changeset(%Author{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).first_name
    end

    test "invalid changeset with missing last_name" do
      attrs = %{first_name: "Jane"}
      changeset = Author.changeset(%Author{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).last_name
    end

    test "invalid changeset with empty attributes" do
      changeset = Author.changeset(%Author{}, %{})

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).first_name
      assert "can't be blank" in errors_on(changeset).last_name
    end
  end
end
