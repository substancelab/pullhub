defmodule Pullhub.PullRequestsFetcher do
  require Logger

  use GenServer


  import Ecto.Query


  alias Pullhub.Repo
  alias Pullhub.User
  alias Pullhub.GithubApi
  alias Pullhub.Repository
  alias Pullhub.PullRequest
  alias Pullhub.RepositoriesService

  def start_link(opts \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], opts)
  end

  def fetch(fetch_params) do
    GenServer.cast(:pull_requests_fetcher, {:fetch, fetch_params})
  end

  def handle_cast({:fetch, fetch_params}, state) do
    {:noreply, fetch}
  end

  def init([]) do
    schedule_work()
    {:ok, []}
  end

  def fetch do
    Repo.all(User)
    |> Enum.filter(fn(u) -> u.github_token != nil end)
    |> Enum.map(&fetch_and_update_pull_requests/1)
  end

  def fetch_and_update_pull_requests(user) do
    client = Tentacat.Client.new(%{access_token: user.github_token})
    user.id
    |> Repository.enabled_repositories
    |> Repo.all
    |> update_pull_requests(user, client)
  end

  def update_pull_requests(repositories, user, client) do
    Enum.map(repositories, fn(repo) ->
      Pullhub.GithubApi.pull_requests(repo, user)
      |> Enum.map(&extract_pull_info/1)
      |> upsert_pulls(repo)
    end)
  end

  defp upsert_pulls(pulls, repo) do
    Enum.map(pulls, fn(pull) ->
      query = from p in PullRequest, where: p.remote_id == ^pull.remote_id and p.repository_id == ^repo.id

      pull = Map.put(pull, :repository_id, repo.id)

      if !Repo.one(query) do
        Repo.insert(PullRequest.changeset(%PullRequest{}, pull))
      else
        Repo.update(PullRequest.changeset(Repo.one(query), pull))
      end
    end)
  end

  defp extract_pull_info(pull) do
    %{
      assignees_logins: Enum.map(pull["assignees"], fn(user) -> user["login"] end),
      body: pull["body"],
      issue_url: pull["issue_url"],
      remote_id: pull["id"],
      repository_id: nil,
      state: pull["state"],
      title: pull["title"],
      url: pull["html_url"],
      author_login: pull["user"]["login"]
    }
  end

  def convert_repository_to_structs(repos, user) do
    Enum.map(repos, fn(repo) -> %{
      name: repo.name,
      owner: repo.owner,
      remote_id: repo.remote_id,
      user_id: user.id
    } end)
  end

  def handle_info(:fetch, state) do
    state = fetch(%{})
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :fetch, 30_000)
  end
end
