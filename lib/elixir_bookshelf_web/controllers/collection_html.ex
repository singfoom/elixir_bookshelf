defmodule ElixirBookshelfWeb.CollectionHTML do
  @moduledoc """
  This module contains pages rendered by CollectionController.

  See the `collection_html` directory for all templates available.
  """
  use ElixirBookshelfWeb, :html

  embed_templates "collection_html/*"
end