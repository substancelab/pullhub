defmodule Pullhub.RepositoryController do
  require Logger
  use Pullhub.Web, :controller

  alias Pullhub.Repository
  alias Pullhub.RepositoriesService

  def index(conn, _params) do
    render(conn, "index.html", repositories: Repo.all(Repository), user_repos: user_repos(conn))
  end

  def create(conn, %{"repositories" => %{"ids" => repository_ids}}) do
    disable_all_user_repositories conn

    case enable_user_repositories conn, repository_ids do
      {:ok, count} ->
        conn
        |> put_flash(:info, "Repositories saved.")
        |> render("index.html", repositories: Repo.all(Repository), user_repos: user_repos(conn))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Repositories ERROR saving.")
        |> render("index.html", repositories: Repo.all(Repository), user_repos: user_repos(conn))
    end
  end

  def fetch_user_repos(conn, _params) do
    Pullhub.RepoFetcher.fetch(%{})
    redirect conn, to: "/repositories"
  end

  def user_id(conn) do
    conn.assigns[:user].id
  end

  def user_repos(conn) do
    user_repos = Repo.all(from( r in Repository, where: r.user_id == ^user_id(conn) ))
  end

  defp disable_all_user_repositories(conn) do
    query = from(r in Repository, where: r.user_id == ^user_id(conn))
    Repo.update_all(query, set: [enabled: false])
  end

  defp enable_user_repositories(conn, repository_ids) do
    query = from(r in Repository, where: r.id in ^repository_ids)
    Repo.update_all(query, set: [enabled: true])

    {:ok, Repo.aggregate(query, :count, :id)}
  end
end
