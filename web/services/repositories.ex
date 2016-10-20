defmodule Pullhub.RepositoriesService do
  require Logger

  def user_repositories(nil) do
    nil
  end

  def user_repositories(user) do
    Tentacat.Client.new(%{access_token: user.github_token})
    |> Tentacat.Repositories.list_mine
    |> simplify_repositories
  end

  def simplify_repositories(repositories) do
    Enum.map(repositories, fn(r) -> %{
      owner: r["owner"]["login"],
      name: r["name"],
      id: r["id"]
    } end)
  end
end
