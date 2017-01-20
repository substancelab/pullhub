defmodule Pullhub.Plugs.GenerateUserToken do
  import Plug.Conn


  def init(default), do: default

  def call(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end
end
