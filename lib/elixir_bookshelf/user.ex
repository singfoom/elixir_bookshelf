defmodule ElixirBookshelf.User do
  @moduledoc """
  The user schema represents a user record for authentication.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          email: String.t(),
          password_hash: String.t(),
          first_name: String.t() | nil,
          last_name: String.t() | nil
        }

  @primary_key {:id, UXID, autogenerate: true, prefix: "usr", size: :medium}
  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :first_name, :last_name, :password, :password_confirmation])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/, message: "must be a valid email")
    |> validate_length(:password, min: 6, message: "must be at least 6 characters")
    |> validate_confirmation(:password, message: "does not match password")
    |> unique_constraint(:email, message: "email already exists")
    |> hash_password()
  end

  @doc false
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> validate_required([:password_confirmation])
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset

  @doc """
  Verifies a password against a user's password hash using bcrypt.
  """
  def verify_password(%__MODULE__{password_hash: password_hash}, password) when is_binary(password_hash) do
    Bcrypt.verify_pass(password, password_hash)
  end

  def verify_password(_user, _password), do: Bcrypt.no_user_verify()
end