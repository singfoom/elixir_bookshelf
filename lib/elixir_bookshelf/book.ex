defmodule ElixirBookshelf.Book do
  @moduledoc """
  The book schema represents a a book record.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirBookshelf.Author

  @type t :: %__MODULE__{
          author_id: String.t() | nil,
          title: String.t(),
          word_count: non_neg_integer()
        }

  @primary_key {:id, UXID, autogenerate: true, prefix: "bk", size: :medium}
  schema "books" do
    field :title, :string
    field :word_count, :integer
    belongs_to :author, Author, type: :string
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :word_count, :author_id])
    |> cast_assoc(:author)
    |> validate_required([:title])
  end
end
