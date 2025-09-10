defmodule ElixirBookshelf.Repo.Migrations.CreateBooksTable do
  use Ecto.Migration
  # excellent_migrations:safety-assured-for-this-file table_dropped

  def up do
    create_if_not_exists table(:books, primary_key: false) do
      add :id, :string, primary_key: true
      add :title, :string
      add :word_count, :integer
      timestamps()
    end
  end

  def down do
    drop_if_exists table(:books)
  end
end
