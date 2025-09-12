defmodule ElixirBookshelf.Repo.Migrations.CreateUsers do
  use Ecto.Migration
  # excellent_migrations:safety-assured-for-this-file table_dropped
  @disable_ddl_transaction true
  @disable_migration_lock true

  def up do
    create_if_not_exists table(:users, primary_key: false) do
      add :id, :string, primary_key: true
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :first_name, :string
      add :last_name, :string

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists unique_index(:users, [:email], concurrently: true)
  end

  def down do
    drop_if_exists index(:users, [:email], concurrently: true)
    drop_if_exists table(:users)
  end
end
