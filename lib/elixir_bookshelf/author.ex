defmodule ElixirBookshelf.Author do
  @moduledoc """
  The author schema represents an author record.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          first_name: String.t(),
          last_name: String.t()
        }

  @primary_key {:id, UXID, autogenerate: true, prefix: "au", size: :medium}
  schema "authors" do
    field :first_name, :string
    field :last_name, :string
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end
end