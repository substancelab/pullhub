defmodule Pullhub.RepoFetcher do
  require Logger

  use GenServer

  alias Pullhub.Repo
  alias Pullhub.User
  alias Pullhub.Repository
  alias Pullhub.RepositoriesService

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    Repo.all(User)
    |> Enum.filter(fn(u) -> u.github_token != nil end)
    |> Enum.map(&fetch_and_update_repositories/1)

    #schedule_work() # Reschedule once more
    {:noreply, state}
  end

  def fetch_and_update_repositories(user) do
    user
    |> RepositoriesService.user_repositories
    |> convert_repository_to_structs(user)
    |> Enum.each(&Repository.find_or_create/1)
  end

  def convert_repository_to_structs(repos, user) do
    Enum.map(repos, fn(repo) -> %Repository{
      name: repo.name,
      owner: repo.owner,
      remote_id: repo.remote_id,
      user_id: user.id
    } end)
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 0 * 1000) # In 30 seconds
  end

end
