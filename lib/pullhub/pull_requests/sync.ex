defmodule Pullhub.PullRequests.Sync do
  alias Pullhub.GithubApi
  alias Pullhub.Repo
  alias Pullhub.Repositories
  alias Pullhub.PullRequests
  alias Pullhub.User

  def sync(%User{} = user) do
    user
    |> enabled_user_repositories
    |> download_pull_requests(user)
  end

  defp download_pull_requests(repositories, %User{} = user) do
    Enum.map(repositories, fn(repo) ->
      Pullhub.GithubApi.pull_requests(repo, user)
      |> update_stored_data(repo)

    end)
    repositories
  end

  defp enabled_user_repositories(%User{} = user) do
    user.id
    |> Repositories.user_repositories
    |> Repositories.enabled_repositories
    |> Repositories.preload_user
    |> Repo.all
  end

  defp update_stored_data({:error, message}, _) do
  end

  defp update_stored_data(pull_requests, repo) do
    PullRequests.remove_pull_requests(repo)
    PullRequests.insert_pull_requests(pull_requests, repo)
  end
end
