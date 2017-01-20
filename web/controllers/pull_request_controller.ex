defmodule Pullhub.PullRequestController do
  require Logger
  use Pullhub.Web, :controller

  alias Pullhub.Repository
  alias Pullhub.PullRequest

  def index(conn, _params) do
    render(conn, "index.html", repositories: user_repos(conn))
  end

  def user_id(conn) do
    conn.assigns[:current_user].id
  end

  def user_repos(conn) do
    user_id(conn)
    |> Repository.user_repositories
    |> Repository.enabled_repositories
    |> preload_pull_requests
    |> preload_users
    |> Repo.all
  end

  def preload_pull_requests(query) do
    from r in query,
        preload: [
          pull_requests: ^Pullhub.PullRequest.open_pull_requests,
        ]
  end

  def preload_users(query) do
    from r in query,
        preload: [
          user: :repositories
        ]
  end
end
