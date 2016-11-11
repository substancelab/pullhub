defmodule Pullhub.RepositoryController do
  require Logger
  use Pullhub.Web, :controller

  alias Pullhub.Repository
  alias Pullhub.RepositoriesService

  def index(conn, _params) do
    render(conn, "index.html", repositories: user_repos(conn))
  end

  def create(conn, %{"repositories" => %{"ids" => repository_ids}}) do
    disable_all_user_repositories conn

    case enable_user_repositories conn, repository_ids do
      {:ok, count} ->
        conn
        |> put_flash(:info, "Repositories saved.")
        |> render("index.html", repositories: user_repos(conn), user_repos: user_repos(conn))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Repositories ERROR saving.")
        |> render("index.html", repositories: user_repos(conn), user_repos: user_repos(conn))
    end
  end

  def user_id(conn) do
    conn.assigns[:user].id
  end

  def user_repos(conn) do
    user_id(conn)
    |> Repository.user_repositories
    |> Repo.all
    |> Repository.sort
  end

  defp disable_all_user_repositories(conn) do
    user_id(conn)
    |> Repository.user_repositories
    |> Repository.enabled_repositories
    |> Repo.update_all(set: [enabled: false])
  end

  defp enable_user_repositories(conn, repository_ids) do
    repository_ids
    |> Repository.find_by_ids
    |> Repo.update_all(set: [enabled: true])

    {:ok, Repo.aggregate(Repository.find_by_ids(repository_ids), :count, :id)}
  end
end
