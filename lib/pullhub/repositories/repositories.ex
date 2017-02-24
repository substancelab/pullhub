defmodule Pullhub.Repositories do

  alias Pullhub.Repository
  alias Pullhub.Repo
  import Ecto
  import Ecto.Query

  @doc """
  Finds one repository based on remote_id. If none is found it is created and returned
  """
  def find_or_create(%Repository{} = repository) do
    query = from r in Repository,
            where: r.remote_id == ^repository.remote_id and r.user_id == ^repository.user_id
    if !Repo.one(query)  do
      Repo.insert(repository)
    end
    Repo.one(query)
  end

  def find_or_create(repository) do
    struct(Repository, repository)
    |> find_or_create
  end

  def sort(query) do
    from( r in query,
      order_by: [desc: :enabled, asc: :name]
    )
  end

  def sorted_user_repositories(user_id) do
    user_repositories(Repository, user_id)
    |> sort
  end

  def all(query) do
    query |> Repo.all
  end

  @doc """
  Finds repositories belonging to user with id = user_id
  """
  def user_repositories(user_id) do
    user_repositories(Repository, user_id)
  end

  def user_repositories(query, user_id) do
    from( r in Repository,
          where: r.user_id == ^user_id
        )
  end

  def without_ids(repo_ids) do
    without_ids(Repository, repo_ids)
  end

  def without_ids(query, repo_ids) do
    from( r in query,
          where: not(r.id in ^repo_ids)
        )
  end

  def preload_user(query) do
    from( r in query,
        preload: [
          user: :repositories
        ]
    )
  end

  def user_repos(user_id) do
    user_id
    |> Repositories.user_repositories
    |> Repositories.enabled_repositories
    |> preload_pull_requests
    |> preload_users
    |> Repo.all
  end

  def preload_pull_requests(query) do
    from r in query,
        preload: [
          pull_requests: ^Pullhub.PullRequests.open_pull_requests,
        ]
  end

  def preload_users(query) do
    from r in query,
        preload: [
          user: :repositories
        ]
  end

  @doc """
  Finds repositories marked as enabled
  """
  def enabled_repositories(query) do
    from( r in query,
          where: r.enabled == true
        )
  end

  @doc """
  Finds repositories by a list of ids
  """
  def find_by_ids(repository_ids) do
    from(r in Repository, where: r.id in ^repository_ids)
  end

  def disable_all_user_repositories(user_id, repository_ids_to_enable) do
    user_id
    |> user_repositories
    |> enabled_repositories
    |> without_ids(repository_ids_to_enable)
    |> Repo.update_all(set: [enabled: false])
  end

  def enable_user_repositories(user_id, repository_ids) do
    repository_ids
    |> find_by_ids
    |> Repo.update_all(set: [enabled: true])

    {:ok, Repo.aggregate(find_by_ids(repository_ids), :count, :id)}
  end
end
