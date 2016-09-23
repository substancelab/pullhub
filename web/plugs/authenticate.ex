defmodule Pullhub.Plugs.Authenticate do
  import Plug.Conn

  def init(default), do: default

  def call(conn, default), do: assign(conn, :user, get_session(conn, :current_user))
end
