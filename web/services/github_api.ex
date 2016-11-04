defmodule Pullhub.GithubApi do
  require Logger

  alias Pullhub.Repo

  def user_repositories(nil) do
    nil
  end

  def user_repositories(user) do
    Tentacat.Client.new(%{access_token: user.github_token})
    |> Tentacat.Repositories.list_mine
    |> simplify_repositories
    |> convert_repository_to_structs(user)
  end

  def pull_requests(repo, user) do
    client = Tentacat.Client.new(%{access_token: user.github_token})
    Tentacat.Pulls.filter(repo.owner, repo.name, [state: "all"], client)
  end

  defp simplify_repositories(repositories) do
    Enum.map(repositories, fn(r) -> %{
      owner: r["owner"]["login"],
      name: r["name"],
      remote_id: r["id"]
    } end)
  end

  defp convert_repository_to_structs(repos, user) do
    Enum.map(repos, fn(repo) -> %{
      name: repo.name,
      owner: repo.owner,
      remote_id: repo.remote_id,
      user_id: user.id
    } end)
  end
end
