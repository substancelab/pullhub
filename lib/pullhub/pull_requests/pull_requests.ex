defmodule Pullhub.PullRequests do

  import Pullhub.PullRequests.Queries

  alias Pullhub.Repository
  alias Pullhub.PullRequest
  alias Pullhub.Repo

  def insert_pull_requests(pull_requests, %Repository{id: repo_id}) do
    pull_requests
    |> Enum.map(&add_repository_id_to_pull_request(&1, repo_id))
    |> insert_pull_requests
  end

  defp insert_pull_requests(pulls) do
    pulls
    |> Enum.map(fn(pull) -> Repo.insert(pull) end)
  end

  def pull_requests(%Repository{id: repo_id} = repo) do
    repo
    |> find_by_repository
    |> Repo.all
  end

  def remove_pull_requests(%Repository{id: repo_id} = repo) do
    repo
    |> find_by_repository
    |> Repo.delete_all
  end

  defp add_repository_id_to_pull_request(%PullRequest{} = pull, repo_id) do
    %{ pull | repository_id: repo_id }
  end
end
