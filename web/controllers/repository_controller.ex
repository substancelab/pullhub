defmodule Pullhub.RepositoryController do
  require Logger
  use Pullhub.Web, :controller

  alias Pullhub.Repository
  alias Pullhub.RepositoriesService

  def index(conn, _params) do
    render(conn, "index.html", repositories: all_repositories(conn), user_repos: user_repos(conn))
  end

  def create(conn, %{"repositories" => %{"ids" => repository_ids}}) do
    delete_existing_user_repositories conn

    case create_user_repositories conn, repository_ids do
      {:ok, count} ->
        conn
        |> put_flash(:info, "Repositories saved.")
        |> render("index.html", repositories: all_repositories(conn), user_repos: user_repos(conn))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Repositories ERRROR saving.")
        |> render("index.html", repositories: all_repositories(conn), user_repos: user_repos(conn))
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

  def all_repositories(conn) do
    Repo.all(Repository)
    #RepositoriesService.user_repositories(conn.assigns[:user])
  end

  def delete_existing_user_repositories(conn) do
    from(r in Repository, where: r.user_id == ^user_id(conn))
    |> Repo.delete_all
  end

  def create_user_repositories(conn, repository_ids) do
    {:ok, inserted_at} = Ecto.DateTime.cast(DateTime.utc_now())

    entries = Enum.map(repository_ids, fn(repo_id) ->
      {remote_id, _} = Integer.parse(repo_id)
      %{
        remote_id: remote_id,
        user_id: user_id(conn),
        name: "",
        inserted_at: inserted_at,
        updated_at: inserted_at
      }
    end)

    {count, nil} = Repo.insert_all(Repository, entries)
    {:ok, count}
  end
end
