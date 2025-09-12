# ElixirBookshelf

A personal book management application built with Phoenix and Elixir. Track your book collection with authors, titles, and word counts.

## Getting Started

To set up and run the ElixirBookshelf application:

### 1. Install Dependencies and Setup Database

```bash
mix setup
```

This command will:
- Install all dependencies
- Create the database
- Run migrations
- Set up assets

### 2. Run Database Migrations

```bash
mix ecto.migrate
```

### 3. Seed the Database

Populate the database with sample books and authors:

```bash
mix run priv/repo/seeds.exs
```

This will create 10 classic science fiction books with their associated authors.

### 4. Start the Phoenix Server

```bash
mix phx.server
```

Or start it inside an IEx session:

```bash
iex -S mix phx.server
```

### 5. View Your Bookshelf

Visit [`localhost:4000`](http://localhost:4000) in your browser to see your book collection!

The homepage displays all books in a clean, responsive grid layout showing:
- Book titles
- Author names
- Word counts
