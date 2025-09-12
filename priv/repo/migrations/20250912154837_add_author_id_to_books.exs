defmodule ElixirBookshelf.Repo.Migrations.AddAuthorIdToBooks do
  use Ecto.Migration
  # excellent_migrations:safety-assured-for-this-file column_removed

  def up do
    alter table(:books) do
      add_if_not_exists :author_id, references(:authors, type: :string, on_delete: :nothing)
    end
  end

  def down do
    alter table(:books) do
      remove_if_exists :author_id, references(:authors, type: :string, on_delete: :nothing)
    end
  end
end
