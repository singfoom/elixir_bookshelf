defmodule ElixirBookshelf.Authors do
  @moduledoc """
  The Authors context for CRUD operations on author records.
  """
  import Ecto.Query, warn: false

  alias ElixirBookshelf.Author
  alias ElixirBookshelf.Repo

  @spec list_authors() :: list(Author.t())
  def list_authors() do
    Repo.all(Author)
  end

  @spec get_author(String.t()) :: Author.t()
  def get_author(author_id) do
    Repo.get(Author, author_id)
  end

  @spec get_author!(String.t()) :: Author.t()
  def get_author!(author_id) do
    Repo.get!(Author, author_id)
  end

  @spec create_author(map()) :: {:ok, Author.t()} | {:error, Ecto.Changeset.t()}
  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_author(Author.t(), map()) :: {:ok, Author.t()} | {:error, Ecto.Changeset.t()}
  def update_author(%Author{} = author, attrs) do
    author
    |> Author.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_author(Author.t()) :: {:ok, Author.t()} | {:error, Ecto.Changeset.t()}
  def delete_author(%Author{} = author) do
    Repo.delete(author)
  end
end
