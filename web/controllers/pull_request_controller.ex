defmodule Pullhub.PullRequestController do
  require Logger
  use Pullhub.Web, :controller

  alias Pullhub.Repository

  def index(conn, _params) do
    render(conn, "index.html", repositories: user_repos(conn))
  end

  def user_id(conn) do
    conn.assigns[:user].id
  end

  def user_repos(conn) do
    user_repos = Repo.all(from( r in Repository, where: r.user_id == ^user_id(conn) and r.enabled == true, preload: [pull_requests: :repository, user: :repositories] ))
    |> Enum.filter(fn(repo) -> Enum.count(repo.pull_requests) > 0 end)
  end
end
