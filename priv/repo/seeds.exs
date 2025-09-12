# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirBookshelf.Repo.insert!(%ElixirBookshelf.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ElixirBookshelf.Repo
alias ElixirBookshelf.{Author, Book}

# Clear existing data
Repo.delete_all(Book)
Repo.delete_all(Author)

# Create authors and books
books_data = [
  {
    %{first_name: "Frank", last_name: "Herbert"},
    %{title: "Dune", word_count: 188_000}
  },
  {
    %{first_name: "Isaac", last_name: "Asimov"},
    %{title: "Foundation", word_count: 244_000}
  },
  {
    %{first_name: "Ursula K.", last_name: "Le Guin"},
    %{title: "The Left Hand of Darkness", word_count: 82_000}
  },
  {
    %{first_name: "Philip K.", last_name: "Dick"},
    %{title: "Do Androids Dream of Electric Sheep?", word_count: 66_000}
  },
  {
    %{first_name: "Douglas", last_name: "Adams"},
    %{title: "The Hitchhiker's Guide to the Galaxy", word_count: 46_000}
  },
  {
    %{first_name: "Ray", last_name: "Bradbury"},
    %{title: "Fahrenheit 451", word_count: 46_000}
  },
  {
    %{first_name: "Orson Scott", last_name: "Card"},
    %{title: "Ender's Game", word_count: 100_000}
  },
  {
    %{first_name: "Kim Stanley", last_name: "Robinson"},
    %{title: "Red Mars", word_count: 190_000}
  },
  {
    %{first_name: "Neal", last_name: "Stephenson"},
    %{title: "Snow Crash", word_count: 147_000}
  },
  {
    %{first_name: "William", last_name: "Gibson"},
    %{title: "Neuromancer", word_count: 104_000}
  }
]

Enum.each(books_data, fn {author_attrs, book_attrs} ->
  author = Repo.insert!(%Author{
    first_name: author_attrs.first_name,
    last_name: author_attrs.last_name
  })
  
  Repo.insert!(%Book{
    title: book_attrs.title,
    word_count: book_attrs.word_count,
    author_id: author.id
  })
end)

IO.puts("Seeded #{length(books_data)} books with authors!")
