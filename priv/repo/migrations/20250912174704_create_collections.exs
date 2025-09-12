defmodule ElixirBookshelf.Repo.Migrations.CreateCollections do
  use Ecto.Migration
  # excellent_migrations:safety-assured-for-this-file table_dropped
  @disable_ddl_transaction true
  @disable_migration_lock true

  def up do
    create_if_not_exists table(:collections, primary_key: false) do
      add :id, :string, primary_key: true
      add :user_id, :string, null: false
      add :book_id, :string, null: false
      add :added_at, :utc_datetime, null: false, default: fragment("now()")

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists unique_index(:collections, [:user_id, :book_id], concurrently: true)
    create_if_not_exists index(:collections, [:user_id], concurrently: true)
    create_if_not_exists index(:collections, [:book_id], concurrently: true)
  end

  def down do
    drop_if_exists index(:collections, [:book_id], concurrently: true)
    drop_if_exists index(:collections, [:user_id], concurrently: true)
    drop_if_exists index(:collections, [:user_id, :book_id], concurrently: true)
    drop_if_exists table(:collections)
  end
end
