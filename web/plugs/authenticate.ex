defmodule Pullhub.Plugs.Authenticate do
  import Plug.Conn


  def init(default), do: default

  def call(conn, default) do
    update_session(get_session(conn, :current_user), conn)
  end

  defp update_session(nil, conn) do
    Phoenix.Controller.redirect(conn, to: Pullhub.Router.Helpers.auth_path(conn, :index))
  end

  defp update_session(user, conn) do
    assign(conn, :user, get_session(conn, :current_user))
  end
end
