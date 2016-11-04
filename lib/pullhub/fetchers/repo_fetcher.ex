defmodule Pullhub.RepoFetcher do
  require Logger

  use GenServer

  alias Pullhub.Repo
  alias Pullhub.User
  alias Pullhub.Repository
  alias Pullhub.RepositoriesService

  def start_link(opts \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], opts)
  end

  def fetch(fetch_params) do
    GenServer.cast(:repo_fetcher, {:fetch, fetch_params})
  end

  def handle_cast({:fetch, fetch_params}, state) do
    {:noreply, fetch}
  end

  def init([]) do
    {:ok, []}
  end

  def fetch do
    Repo.all(User)
    |> Enum.filter(fn(u) -> u.github_token != nil end)
    |> Enum.map(&fetch_and_update_repositories/1)
  end

  def fetch_and_update_repositories(user) do
    user
    |> RepositoriesService.user_repositories
    |> convert_repository_to_structs(user)
    |> Enum.each(&Repository.find_or_create/1)
  end

  def convert_repository_to_structs(repos, user) do
    Enum.map(repos, fn(repo) -> %{
      name: repo.name,
      owner: repo.owner,
      remote_id: repo.remote_id,
      user_id: user.id
    } end)
  end
end
