defmodule Pullhub.PullRequestsTest do
  use Pullhub.ModelCase

  alias Pullhub.User
  alias Pullhub.Repositories
  alias Pullhub.PullRequests
  alias Pullhub.PullRequest

  defp pull_request_struct do
    %PullRequest{
      assignees_avatars: [],
      assignees_logins: [],
      body: "body",
      issue_url: "issue_url",
      remote_id: 1232123,
      repository_id: nil,
      state: "state",
      title: "title",
      url: "html_url",
      author_login: "user"
    }
  end

  test "can insert pull requests" do
    user = Pullhub.Accounts.find_or_create(%User{email: "jd@testemail.com"})

    new_repo = %{remote_id: 11, name: "t", owner: "1", user_id: user.id}
    |> Repositories.find_or_create

    [pull_request_struct, pull_request_struct]
    |> PullRequests.insert_pull_requests(new_repo)

    assert Pullhub.Repo.count(PullRequest) == 2
  end

  test "can find pull requests for a given repository" do
    user = Pullhub.Accounts.find_or_create(%User{email: "jd@testemail.com"})

    new_repo = %{remote_id: 11, name: "t", owner: "1", user_id: user.id}
    |> Repositories.find_or_create

    other_repo = %{remote_id: 14, name: "s", owner: "3123", user_id: user.id}
    |> Repositories.find_or_create

    [pull_request_struct, pull_request_struct]
    |> PullRequests.insert_pull_requests(new_repo)

    [pull_request_struct]
    |> PullRequests.insert_pull_requests(other_repo)

    assert Pullhub.Repo.count(PullRequest) == 3
    assert Pullhub.Repo.count(PullRequests.Queries.find_by_repository(new_repo)) == 2
  end

  test "can remove pull requests for a given repository" do
    user = Pullhub.Accounts.find_or_create(%User{email: "jd@testemail.com"})

    new_repo = %{remote_id: 11, name: "t", owner: "1", user_id: user.id}
    |> Repositories.find_or_create

    other_repo = %{remote_id: 14, name: "s", owner: "3123", user_id: user.id}
    |> Repositories.find_or_create

    [pull_request_struct, pull_request_struct]
    |> PullRequests.insert_pull_requests(new_repo)

    [pull_request_struct]
    |> PullRequests.insert_pull_requests(other_repo)

    PullRequests.remove_pull_requests(new_repo)

    assert Pullhub.Repo.count(PullRequest) == 1
    assert Pullhub.Repo.count(PullRequests.Queries.find_by_repository(new_repo)) == 0
  end


  test "can find open pull requests" do
    user = Pullhub.Accounts.find_or_create(%User{email: "jd@testemail.com"})

    new_repo = %{remote_id: 11, name: "t", owner: "1", user_id: user.id}
    |> Repositories.find_or_create

    other_repo = %{remote_id: 14, name: "s", owner: "3123", user_id: user.id}
    |> Repositories.find_or_create

    [pull_request_struct, pull_request_struct]
    |> PullRequests.insert_pull_requests(new_repo)

    [pull_request_struct]
    |> PullRequests.insert_pull_requests(other_repo)

    PullRequests.remove_pull_requests(new_repo)

    assert Pullhub.Repo.count(PullRequest) == 1
    assert Pullhub.Repo.count(PullRequests.Queries.find_by_repository(new_repo)) == 0
  end
end
