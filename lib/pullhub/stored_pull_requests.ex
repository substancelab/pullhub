defmodule Pullhub.StoredPullRequests do
  import Ecto.Query

  alias Pullhub.PullRequest
  alias Pullhub.Repo
  alias Pullhub.Repository

  def insert_pull_requests(pull_requests, %Repository{id: repo_id}) do
    pull_requests
    |> Enum.map(&add_repository_id_to_pull_request(&1, repo_id))
    |> insert_pull_requests
  end

  def pull_requests(%Repository{id: repo_id}) do
    from p in PullRequest, where: p.repository_id == ^repo_id
  end

  defp insert_pull_requests(pulls) do
    pulls
    |> Enum.map(fn(pull) -> Repo.insert(pull) end)
  end

  def remove_pull_requests(%Repository{id: repo_id} = repo) do
    pull_requests(repo)
    |> Repo.delete_all
  end

  defp add_repository_id_to_pull_request(%PullRequest{} = pull, repo_id) do
    %{ pull | repository_id: repo_id }
  end
end
