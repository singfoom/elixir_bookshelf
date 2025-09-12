defmodule ElixirBookshelf.Collections do
  @moduledoc """
  The Collections context for CRUD operations on collection records.
  """
  import Ecto.Query, warn: false

  alias ElixirBookshelf.Collection
  alias ElixirBookshelf.Repo

  @spec list_collections() :: list(Collection.t())
  def list_collections() do
    Collection
    |> Repo.all()
    |> Repo.preload([:user, book: :author])
  end

  @spec get_collection(String.t()) :: Collection.t() | nil
  def get_collection(collection_id) do
    Collection
    |> Repo.get(collection_id)
    |> case do
      nil -> nil
      collection -> Repo.preload(collection, [:user, book: :author])
    end
  end

  @spec get_collection!(String.t()) :: Collection.t()
  def get_collection!(collection_id) do
    Collection
    |> Repo.get!(collection_id)
    |> Repo.preload([:user, book: :author])
  end

  @spec create_collection(map) :: {:ok, Collection.t()} | {:error, Ecto.Changeset.t()}
  def create_collection(attrs \\ %{}) do
    %Collection{}
    |> Collection.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_collection(Collection.t(), map()) :: {:ok, Collection.t()} | {:error, Ecto.Changeset.t()}
  def update_collection(%Collection{} = collection, attrs) do
    collection
    |> Collection.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_collection(Collection.t()) :: {:ok, Collection.t()} | {:error, Ecto.Changeset.t()}
  def delete_collection(%Collection{} = collection) do
    Repo.delete(collection)
  end

  @spec list_collections_by_user(String.t()) :: list(Collection.t())
  def list_collections_by_user(user_id) do
    Collection
    |> where([c], c.user_id == ^user_id)
    |> Repo.all()
    |> Repo.preload([:user, book: :author])
  end

  @spec get_collection_by_user_and_book(String.t(), String.t()) :: Collection.t() | nil
  def get_collection_by_user_and_book(user_id, book_id) do
    Collection
    |> where([c], c.user_id == ^user_id and c.book_id == ^book_id)
    |> Repo.one()
    |> case do
      nil -> nil
      collection -> Repo.preload(collection, [:user, book: :author])
    end
  end

  @spec user_has_book?(String.t(), String.t()) :: boolean()
  def user_has_book?(user_id, book_id) do
    Collection
    |> where([c], c.user_id == ^user_id and c.book_id == ^book_id)
    |> Repo.exists?()
  end

  @spec add_book_to_user_collection(String.t(), String.t()) :: {:ok, Collection.t()} | {:error, Ecto.Changeset.t()}
  def add_book_to_user_collection(user_id, book_id) do
    create_collection(%{user_id: user_id, book_id: book_id})
  end

  @spec remove_book_from_user_collection(String.t(), String.t()) :: {:ok, Collection.t()} | {:error, :not_found}
  def remove_book_from_user_collection(user_id, book_id) do
    case get_collection_by_user_and_book(user_id, book_id) do
      nil -> {:error, :not_found}
      collection -> delete_collection(collection)
    end
  end
end