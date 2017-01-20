defmodule Pullhub.Plugs.Authenticate do
  require Logger
  import Plug.Conn
  alias Pullhub.Router.Helpers, as: RouteHelpers
  import Phoenix.Controller

  alias Pullhub.Repo
  alias Pullhub.User

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> get_user
    |> update_auth_state(conn)
  end

  def update_auth_state(%User{} = user, conn) do
    assign(conn, :current_user, user)
  end

  def update_auth_state(_, conn) do
    auth_error!(conn)
  end

  defp get_user(conn) do
    case conn.assigns[:current_user] do
      nil      -> fetch_user(conn)
      user     -> user
    end
  end

  defp fetch_user(conn) do
    get_session(conn, :current_user)
    |> find_user
  end

  defp find_user(nil) do
    nil
  end

  defp find_user(user) do
    Repo.get(User, user.id)
  end

  defp auth_error!(conn) do
    conn
    |> put_flash(:error, "You need to be signed in to view this page")
    |> redirect(to: RouteHelpers.auth_path(conn, :index))
    |> halt
  end
end
