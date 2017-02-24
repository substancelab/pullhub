defmodule Pullhub.Repositories.Queries do

  import Ecto.Query

  alias Pullhub.PullRequests
  alias Pullhub.Repository

  def enabled_repositories(query), do: query |> where(enabled: true)

  def find_by_ids(ids), do: Repository |> where([r], r.id in ^ids)

  def find_by_remote_id_and_user_id(%Repository{} = repository) do
    Repository
    |> where([r], r.remote_id == ^repository.remote_id and
                  r.user_id == ^repository.user_id)
  end

  def preload_pull_requests(query) do
    query |> preload( pull_requests: ^PullRequests.open_pull_requests)
  end

  def preload_users(query), do: query |> preload(user: :repositories)

  def sort(query), do: query |> order_by([desc: :enabled, asc: :name])

  def user_repositories(query, user_id), do: query |> where(user_id: ^user_id)
  def user_repositories(user_id), do: Repository |> user_repositories(user_id)

  def without_ids(query, ids), do: query |> where([r], not(r.id in ^ids))
  def without_ids(ids), do: Repository |> without_ids(ids)
end
