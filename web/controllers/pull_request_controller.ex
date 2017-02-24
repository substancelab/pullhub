defmodule Pullhub.PullRequestController do
  use Pullhub.Web, :controller

  alias Pullhub.Repositories

  def index(conn, _params) do
    conn
    |> assign(:page_title, "Pull requests")
    |> render("index.html", repositories: user_repos(conn))
  end

  def user_id(conn) do
    conn.assigns[:current_user].id
  end

  def user_repos(conn) do
    user_id(conn)
    |> Repositories.user_repos
  end
end
