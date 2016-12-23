defmodule Pullhub.GithubApi do
  require Logger

  alias Pullhub.PullRequest
  alias Pullhub.Repo
  alias Pullhub.Repository
  alias Pullhub.User

  def hooks(repo, %User{} = user) do
    client = Tentacat.Client.new(%{access_token: user.github_token})
    Tentacat.Hooks.list(repo.owner, repo.name, client)
  end

  def create_hook(repo, %User{} = user) do
    client = Tentacat.Client.new(%{access_token: user.github_token})
    Tentacat.Hooks.create(repo.owner, repo.name, client, hook_configuration)
  end

  def remove_hook(repo, %User{} = user) do
    client = Tentacat.Client.new(%{access_token: user.github_token})
    Tentacat.Hooks.remove(repo.owner, repo.name, client, hook_configuration)
  end

  def repositories(nil) do
    nil
  end

  def repositories(%User{} = user) do
    Tentacat.Client.new(%{access_token: user.github_token})
    |> Tentacat.Repositories.list_mine
    |> to_struct(user)
  end

  def pull_requests(repo, %User{} = user) do
    client = Tentacat.Client.new(%{access_token: user.github_token})
    Tentacat.Pulls.list(repo.owner, repo.name, client)
    |> to_struct
  end

  def hook_configuration do
    %{
      name: "pullhub",
      active: true,
      events: [ "push", "pull_request" ],
      config: %{
        url: "https://pullhub.herokuapp.com/github_webhook",
        content_type: "json"
      }
    }
  end


  defp assigness_from_pull(pull) do
    Enum.map(pull["assignees"], fn(user) -> user["login"] end)
  end

  defp extract_pull_info(pull) do
    %PullRequest{
      assignees_logins: assigness_from_pull(pull),
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

  defp extract_repo_info(repo, user) do
    %Repository{
      name: repo["name"],
      owner: repo["owner"]["login"],
      remote_id: repo["id"],
      user_id: user.id
    }
  end

  # handle errors from github
  defp to_struct({response_code, %{"message" => message} = payload}) do
    {:error, message}
  end

  defp to_struct(github_data) do
    Enum.map(github_data, &extract_pull_info/1)
  end

  defp to_struct(repos, %User{} = user) do
    Enum.map(repos, &extract_repo_info(&1, user))
  end
end
