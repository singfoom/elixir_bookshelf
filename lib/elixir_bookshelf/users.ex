defmodule ElixirBookshelf.Users do
  @moduledoc """
  The Users context for CRUD operations on user records.
  """
  import Ecto.Query, warn: false

  alias ElixirBookshelf.User
  alias ElixirBookshelf.Repo

  @spec list_users() :: list(User.t())
  def list_users() do
    Repo.all(User)
  end

  @spec get_user(String.t()) :: User.t() | nil
  def get_user(user_id) do
    Repo.get(User, user_id)
  end

  @spec get_user!(String.t()) :: User.t()
  def get_user!(user_id) do
    Repo.get!(User, user_id)
  end

  @spec get_user_by_email(String.t()) :: User.t() | nil
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @spec register_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @spec update_user(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @spec change_user(User.t(), map()) :: Ecto.Changeset.t()
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @spec authenticate_user(String.t(), String.t()) :: {:ok, User.t()} | {:error, :invalid_credentials}
  def authenticate_user(email, password) do
    case get_user_by_email(email) do
      %User{} = user ->
        if User.verify_password(user, password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
      
      nil ->
        # Run password verification anyway to prevent timing attacks
        User.verify_password(%User{password_hash: "dummy"}, password)
        {:error, :invalid_credentials}
    end
  end
end