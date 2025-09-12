defmodule ElixirBookshelfWeb.Plugs.Auth do
  @moduledoc """
  Authentication plug that loads the current user from the session.
  """
  
  import Plug.Conn
  alias ElixirBookshelf.Users

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user_id = get_session(conn, :current_user_id)
    
    if current_user = current_user_id && Users.get_user(current_user_id) do
      assign(conn, :current_user, current_user)
    else
      assign(conn, :current_user, nil)
    end
  end
end