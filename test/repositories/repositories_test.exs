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

    sorted = Repositories.Queries.user_repositories(user.id)
            |> Repositories.Queries.sort
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


    query = Repositories.Queries.without_ids([first_repo.id, second_repo.id])
    assert Pullhub.Repo.all(query) == [third_repo]
  end

  test "finds repositories owned by a specific user" do
    user = Pullhub.Accounts.find_or_create(%User{email: "jd@testemail.com"})
    other_user = Pullhub.Accounts.find_or_create(%User{email: "jd@terestemail.com"})

    first_repo = %{remote_id: 11, name: "a", owner: "1", user_id: user.id}
    |> Repositories.find_or_create

    second_repo = %{remote_id: 12, name: "b", owner: "1", user_id: user.id}
    |> Repositories.find_or_create

    third_repo = %{remote_id: 13, name: "c", owner: "1", user_id: user.id}
    |> Repositories.find_or_create

    %{remote_id: 13, name: "t", owner: "1", user_id: other_user.id}
    |> Repositories.find_or_create

    sorted_user_repositories = Repositories.sorted_user_repositories(user.id)
    assert sorted_user_repositories == [first_repo, second_repo, third_repo]
  end

  test "can enable repositories owned by a specific user" do
    user = Pullhub.Accounts.find_or_create(%User{email: "jd@testemail.com"})
    other_user = Pullhub.Accounts.find_or_create(%User{email: "jd@terestemail.com"})

    first_repo = %{remote_id: 11, name: "a", enabled: false, owner: "1", user_id: user.id}
    |> Repositories.find_or_create

    %{remote_id: 12, name: "b", owner: "1", user_id: user.id}
    |> Repositories.find_or_create

    other_repo = %{remote_id: 13, name: "t", owner: "1", user_id: other_user.id}
    |> Repositories.find_or_create

    Repositories.enable_user_repositories(user.id, [first_repo.id, other_repo.id])

    updated_repo = Repositories.find_by_id(first_repo.id)
    assert updated_repo.enabled == true

    updated_other_repo = Repositories.find_by_id(other_repo.id)
    assert updated_other_repo.enabled != true
  end

  test "can disable repositories owned by a specific user" do
    user = Pullhub.Accounts.find_or_create(%User{email: "jd@testemail.com"})
    other_user = Pullhub.Accounts.find_or_create(%User{email: "jd@terestemail.com"})

    first_repo = %{remote_id: 11, name: "a", enabled: true, owner: "1", user_id: user.id}
    |> Repositories.find_or_create

    second_repo = %{remote_id: 12, name: "b", owner: "1", enabled: true, user_id: user.id}
    |> Repositories.find_or_create

    other_repo = %{remote_id: 13, name: "t", owner: "1", enabled: true, user_id: other_user.id}
    |> Repositories.find_or_create

    Repositories.disable_all_user_repositories(user.id, [second_repo.id])

    updated_repo = Repositories.find_by_id(first_repo.id)
    assert updated_repo.enabled == false

    updated_second_repo = Repositories.find_by_id(second_repo.id)
    assert updated_second_repo.enabled == true

    updated_other_repo = Repositories.find_by_id(other_repo.id)
    assert updated_other_repo.enabled == true
  end
end
