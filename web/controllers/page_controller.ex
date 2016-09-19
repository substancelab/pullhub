defmodule Pullhub.PageController do
  use Pullhub.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
