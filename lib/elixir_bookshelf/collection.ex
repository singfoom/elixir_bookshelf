defmodule ElixirBookshelf.Collection do
  @moduledoc """
  The collection schema represents a join table between users and books,
  allowing users to have their own book collections.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirBookshelf.{User, Book}

  @type t :: %__MODULE__{
          user_id: String.t(),
          book_id: String.t(),
          added_at: DateTime.t(),
          user: User.t() | Ecto.Association.NotLoaded.t(),
          book: Book.t() | Ecto.Association.NotLoaded.t()
        }

  @primary_key {:id, UXID, autogenerate: true, prefix: "col", size: :medium}
  schema "collections" do
    field :added_at, :utc_datetime

    belongs_to :user, User, type: :string
    belongs_to :book, Book, type: :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(collection, attrs) do
    collection
    |> cast(attrs, [:user_id, :book_id, :added_at])
    |> validate_required([:user_id, :book_id])
    |> put_added_at_if_missing()
    |> unique_constraint([:user_id, :book_id], message: "book already in collection")
    |> foreign_key_constraint(:user_id, name: "collections_user_id_fkey", message: "user does not exist")
    |> foreign_key_constraint(:book_id, name: "collections_book_id_fkey", message: "book does not exist")
  end

  defp put_added_at_if_missing(%Ecto.Changeset{changes: changes} = changeset) do
    if Map.has_key?(changes, :added_at) do
      changeset
    else
      put_change(changeset, :added_at, DateTime.utc_now() |> DateTime.truncate(:second))
    end
  end
end