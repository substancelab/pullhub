defmodule Pullhub.RepoFetcher do
  use GenServer

  alias Pullhub.GithubApi
  alias Pullhub.Repositories

  def fetch(fetch_params) do
    GenServer.cast(:repo_fetcher, {:fetch_user_github_repositories, fetch_params})
  end

  def handle_cast({:fetch_user_github_repositories, fetch_params}, state) do
    %{user: user} = fetch_params
    {:noreply, fetch_and_update_repositories(user)}
  end

  def init([]) do
    {:ok, []}
  end

  def start_link(opts \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], opts)
  end

  defp fetch_and_update_repositories(user) do
    user
    |> GithubApi.repositories
    |> Enum.map(&Repositories.find_or_create/1)
    |> Repositories.sort
    |> Enum.map(&render_repository/1)
    |> broadcastChannelInfo(user)
  end

  defp broadcastChannelInfo(rendered_repositories, user) do
    Pullhub.Endpoint.broadcast(
      "repository:list:#{user.id}",
      "repositories_updated",
      %{data: rendered_repositories}
    )
  end

  defp render_repository(repository) do
    Phoenix.View.render(
      Pullhub.RepositoryView,
      "repository.html",
      repository: repository
    )
    |> Phoenix.HTML.safe_to_string
  end
end
