defmodule ElixirBookshelf.Repo do
  use Ecto.Repo,
    otp_app: :elixir_bookshelf,
    adapter: Ecto.Adapters.Postgres
end
