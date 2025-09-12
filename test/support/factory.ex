defmodule ElixirBookshelf.Factory do
  @moduledoc """
  An ex machina based factory for data in tests
  """
  use ExMachina.Ecto, repo: ElixirBookshelf.Repo
  alias ElixirBookshelf.{Author, Book}

  def book_factory do
    %Book{
      title:
        Enum.random([
          "On Basilisk Station",
          "The Wheel of Time",
          "Perdido Street Station",
          "SevenEves",
          "Anathema",
          "Authority"
        ]),
      word_count: Enum.random(0..20_000)
    }
  end

  def author_factory do
    %Author{
      first_name:
        Enum.random([
          "Isaac",
          "Ursula",
          "China",
          "Neal",
          "Kim",
          "Jeff"
        ]),
      last_name:
        Enum.random([
          "Asimov",
          "Le Guin",
          "Miéville",
          "Stephenson",
          "Robinson",
          "VanderMeer"
        ])
    }
  end
end
