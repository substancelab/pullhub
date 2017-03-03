defmodule Pullhub.PullRequests.Queries do

  import Ecto.Query

  alias Pullhub.Repository
  alias Pullhub.PullRequest

  def find_by_repository(%Repository{id: repo_id}) do
    PullRequest |> where([p], p.repository_id == ^repo_id)
  end

  def open_pull_requests, do: PullRequest |> where(state: "open")
end
