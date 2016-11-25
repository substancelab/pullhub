defmodule Pullhub.PullRequestsFetcher do
  use GenServer

  alias Pullhub.User
  alias Pullhub.PullRequestsBroadcaster
  alias Pullhub.PullRequestsSync

  def fetch(fetch_params) do
    GenServer.cast(:pull_requests_fetcher,
                  {:fetch_user_pull_requests, fetch_params})
  end

  def fetch_and_update_pull_requests(%User{} = user) do
    user
    |> PullRequestsSync.sync
    |> PullRequestsBroadcaster.broadcast(user)
  end

  def handle_cast({:fetch_user_pull_requests, fetch_params}, state) do
    %{user: user} = fetch_params
    {:noreply, fetch_and_update_pull_requests(user)}
  end

  def init([]) do
    {:ok, []}
  end

  def start_link(opts \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], opts)
  end
end
