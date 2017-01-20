defmodule Pullhub.RepositoryController do
  require Logger
  use Pullhub.Web, :controller

  alias Pullhub.Repository
  alias Pullhub.RepositoriesService

  def index(conn, _params) do
    render(conn, "index.html", repositories: user_repos(conn))
  end

  def create(conn, %{"repositories" => %{"ids" => repository_ids}}) do
    disable_all_user_repositories conn, repository_ids

    case enable_user_repositories conn, repository_ids do
      {:ok, count} ->
        conn
        |> put_flash(:info, "Repositories saved.")
        |> render("index.html", repositories: user_repos(conn))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Repositories ERROR saving.")
        |> render("index.html", repositories: user_repos(conn))
    end
  end

  def user_id(conn) do
    conn.assigns[:current_user].id
  end

  def user_repos(conn) do
    Repository.sorted_user_repositories(user_id(conn))
    |> Repo.all
  end

  defp disable_all_user_repositories(conn, repository_ids_to_enable) do
    user_id(conn)
    |> Repository.disable_all_user_repositories(repository_ids_to_enable)
  end

  defp enable_user_repositories(conn, repository_ids) do
    user_id(conn)
    |> Repository.enable_user_repositories(repository_ids)
  end
end
