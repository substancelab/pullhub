defmodule Pullhub.RepositoriesTest do
  use Pullhub.ModelCase

  alias Pullhub.User
  alias Pullhub.Repository
  alias Pullhub.Repositories

  test "find_or_create creates new if does not exist" do
    user = Pullhub.Accounts.find_or_create(%User{email: "jd@testemail.com"})
    new_repo = %{remote_id: 11, name: "t", owner: "1", user_id: user.id}

    assert Pullhub.Repo.get_by(Repository, new_repo) == nil

    Repositories.find_or_create(new_repo)
    assert Pullhub.Repo.get_by(Repository, new_repo)
  end

  test "find_or_create returns existing one" do
    user = Pullhub.Accounts.find_or_create(%User{email: "jd@testemail.com"})

    new_repo = %{remote_id: 11, name: "t", owner: "1", user_id: user.id}
    Repositories.find_or_create(new_repo)
    Repositories.find_or_create(new_repo)
    assert length(Pullhub.Repo.all(Repository)) == 1
  end

  test "sort sorts the repositories" do
    user = Pullhub.Accounts.find_or_create(%User{email: "jd@testemail.com"})
    repo = %{remote_id: 10, name: "aaaalong", owner: "1", enabled: false, user_id: user.id}
    enabled_repo = %{remote_id: 11, name: "ZZZZebra", owner: "1", enabled: true, user_id: user.id}

    Repositories.find_or_create(repo)
    enabled_repo = Repositories.find_or_create(enabled_repo)

    sorted = Repositories.user_repositories(user.id)
            |> Repositories.sort
    assert hd(Repo.all(sorted)) == enabled_repo
  end

  test "finds repositories with out certain ids" do
    user = Pullhub.Accounts.find_or_create(%User{email: "jd@testemail.com"})

    first_repo = %{remote_id: 11, name: "t", owner: "1", user_id: user.id}
    |> Repositories.find_or_create

    second_repo = %{remote_id: 12, name: "t", owner: "1", user_id: user.id}
    |> Repositories.find_or_create

    third_repo = %{remote_id: 13, name: "t", owner: "1", user_id: user.id}
    |> Repositories.find_or_create


    query = Repositories.without_ids([first_repo.id, second_repo.id])
    assert Pullhub.Repo.all(query) == [third_repo]
  end
end
