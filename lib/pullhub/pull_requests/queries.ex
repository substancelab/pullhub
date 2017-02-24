defmodule Pullhub.PullRequests.Queries do

  import Ecto
  import Ecto.Query

  alias Pullhub.Repository
  alias Pullhub.PullRequest

  def open_pull_requests, do: PullRequest |> where(state: "open")

  def find_by_repository(%Repository{id: repo_id}) do
    PullRequest |> where([p], p.repository_id == ^repo_id)
  end
end
