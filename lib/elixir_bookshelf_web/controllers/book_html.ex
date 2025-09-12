defmodule ElixirBookshelfWeb.BookHTML do
  @moduledoc """
  This module contains pages rendered by BookController.

  See the `book_html` directory for all templates available.
  """
  use ElixirBookshelfWeb, :html

  embed_templates "book_html/*"
end