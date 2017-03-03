defmodule Pullhub.Repositories do

  import Pullhub.Repositories.Queries

  alias Pullhub.Repo
  alias Pullhub.Repository

  @doc """
  Mark all user repositories without ids to exclude as disabled
  """
  def disable_all_user_repositories(user_id, exluded_ids) do
    user_id
    |> user_repositories
    |> enabled_repositories
    |> without_ids(exluded_ids)
    |> Repo.update_all(set: [enabled: false])
  end

  @doc """
  Mark all user repositories with certain ids as enabled
  """
  def enable_user_repositories(user_id, repository_ids) do
    query = repository_ids
    |> find_by_ids
    |> user_repositories(user_id)

    query |> Repo.update_all(set: [enabled: true])

    {:ok, Repo.aggregate(query, :count, :id)}
  end

  def find_by_id(id), do: Repo.get(Repository, id)

  @doc """
  Finds one repository based on remote_id. If none is found it is created and
  returned
  """
  def find_or_create(%Repository{} = repository) do
    query = find_by_remote_id_and_user_id(repository)
    if !Repo.one(query)  do
      Repo.insert(repository)
    end
    Repo.one(query)
  end
  def find_or_create(repo), do: struct(Repository, repo) |> find_or_create

  @doc """
  Finds repositories belonging to user with id = user_id and sorts by name
  """
  def sorted_user_repositories(user_id) do
    Repository
    |> user_repositories(user_id)
    |> sort
    |> Repo.all
  end

  @doc """
  Finds repositories belonging to user with id = user_id
  """
  def user_repos(user_id) do
    user_id
    |> user_repositories
    |> enabled_repositories
    |> preload_pull_requests
    |> preload_users
    |> sort
    |> Repo.all
  end
end
