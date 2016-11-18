defmodule Pullhub.GithubApi do
  require Logger

  alias Pullhub.PullRequest
  alias Pullhub.Repo
  alias Pullhub.Repository
  alias Pullhub.User

  def repositories(nil) do
    nil
  end

  def repositories(%User{} = user) do
    Tentacat.Client.new(%{access_token: user.github_token})
    |> Tentacat.Repositories.list_mine
    |> convert_repositories_to_structs(user)
  end

  def pull_requests(repo, %User{} = user) do
    client = Tentacat.Client.new(%{access_token: user.github_token})
    Tentacat.Pulls.list(repo.owner, repo.name, client)
    |> convert_pull_requests_to_stucts
  end


  # handle errors from github
  defp convert_pull_requests_to_stucts({response_code, %{"message" => message} = payload}) do
    {:error, message}
  end

  defp convert_pull_requests_to_stucts(github_data) do
    Enum.map(github_data, &extract_pull_info/1)
  end

  # handle errors from github
  defp convert_repositories_to_structs({response_code, %{"message" => message} = payload}) do
    {:error, message}
  end

  defp convert_repositories_to_structs(repos, user) do
    Enum.map(repos, fn(repo) -> %Repository{
      name: repo["name"],
      owner: repo["owner"]["login"],
      remote_id: repo["id"],
      user_id: user.id
    } end)
  end

  defp extract_pull_info(pull) do
    %PullRequest{
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
end
