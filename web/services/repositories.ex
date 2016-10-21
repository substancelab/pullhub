defmodule Pullhub.RepositoriesService do
  require Logger

  alias Pullhub.Repo

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
      remote_id: r["id"]
    } end)
  end
end
