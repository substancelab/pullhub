defmodule Pullhub.PullRequestsBroadcaster do
  alias Pullhub.Repo
  alias Pullhub.Repository
  alias Pullhub.PullRequests
  alias Pullhub.User

  def broadcast(repositories, %User{} = user) do
    repositories
    |> prepare_for_broadcasting
    |> perform_broadcast(user)
  end

  defp map_to_structure(pull_requests, %Repository{} = repository) do
    %{
      repository_id: repository.id,
      rendered_pull_requests: render_pull_requests(pull_requests, repository)
    }
  end

  defp perform_broadcast(rendered_repositories, user) do
    Pullhub.Endpoint.broadcast(
      "pull_request:#{user.id}",
      "pull_requests_updated",
      %{data: rendered_repositories}
    )
  end

  defp prepare_for_broadcasting(repositories) do
    Enum.map(repositories, fn(repo) ->
      PullRequests.pull_requests(repo)
      |> map_to_structure(repo)
    end)
  end

  defp render_pull_requests(pull_requests, repository) do
    Enum.map(pull_requests, render_pull_request_to_string(repository))
  end

  defp render_pull_request_to_string(repository) do
    fn(pull_request) ->
      Phoenix.View.render(
        Pullhub.PullRequestView,
        "pull_request.html",
        repository: repository,
        pull_request: pull_request
      )
      |> Phoenix.HTML.safe_to_string
    end
  end
end
