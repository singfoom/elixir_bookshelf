defmodule ElixirBookshelf.Repo.Migrations.CreateAuthors do
  use Ecto.Migration
  # excellent_migrations:safety-assured-for-this-file table_dropped

  def up do
    create_if_not_exists table(:authors, primary_key: false) do
      add :id, :string, primary_key: true
      add :first_name, :string, null: false
      add :last_name, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end

  def down do
    drop_if_exists table(:authors)
  end
end
