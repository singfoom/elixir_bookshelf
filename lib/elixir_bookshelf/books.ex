defmodule ElixirBookshelf.Books do
  @moduledoc """
  The Books context for CRUD operations on book records.
  """
  import Ecto.Query, warn: false

  alias ElixirBookshelf.Book
  alias ElixirBookshelf.Repo

  @spec list_books() :: list(Book.t())
  def list_books() do
    Repo.all(Book)
  end

  @spec get_book(String.t()) :: Book.t()
  def get_book(book_id) do
    Repo.get(Book, book_id)
  end

  @spec get_book!(String.t()) :: Book.t()
  def get_book!(book_id) do
    Repo.get!(Book, book_id)
  end

  @spec create_book(map) :: {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_book(Book.t(), map()) :: {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_book(Book.t()) :: {:ok, Book.t()} | {:error, Ecto.Changeset.t()}
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end
end
