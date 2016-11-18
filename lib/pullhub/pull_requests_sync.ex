defmodule Pullhub.PullRequestsSync do
  alias Pullhub.GithubApi
  alias Pullhub.Repo
  alias Pullhub.Repository
  alias Pullhub.StoredPullRequests
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
    |> Repository.user_repositories
    |> Repository.enabled_repositories
    |> Repository.preload_user
    |> Repo.all
  end

  defp update_stored_data({:error, message}, _) do
  end

  defp update_stored_data(pull_requests, repo) do
    StoredPullRequests.remove_pull_requests(repo)
    StoredPullRequests.insert_pull_requests(pull_requests, repo)
  end
end
