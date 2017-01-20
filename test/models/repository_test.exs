defmodule Pullhub.RepositoryTest do
  use Pullhub.ModelCase

  alias Pullhub.Repository

  @valid_attrs %{name: "some content", remote_id: 42, owner: "me"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Repository.changeset(%Repository{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Repository.changeset(%Repository{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "find_or_create creates new if does not exist" do
    user = Pullhub.User.find_or_create(%{email: "jd@testemail.com"})
    new_repo = %{remote_id: 11, name: "t", owner: "1", user_id: user.id}

    assert Pullhub.Repo.get_by(Repository, new_repo) == nil

    Repository.find_or_create(new_repo)
    assert Pullhub.Repo.get_by(Repository, new_repo)
  end

  test "find_or_create returns existing one" do
    user = Pullhub.User.find_or_create(%{email: "jd@testemail.com"})

    new_repo = %{remote_id: 11, name: "t", owner: "1", user_id: user.id}
    Repository.find_or_create(new_repo)
    Repository.find_or_create(new_repo)
    assert length(Pullhub.Repo.all(Repository)) == 1
  end

  test "sort sorts the repositories" do
    user = Pullhub.User.find_or_create(%{email: "jd@testemail.com"})
    repo = %{remote_id: 10, name: "aaaalong", owner: "1", enabled: false, user_id: user.id}
    enabled_repo = %{remote_id: 11, name: "ZZZZebra", owner: "1", enabled: true, user_id: user.id}

    Repository.find_or_create(repo)
    enabled_repo = Repository.find_or_create(enabled_repo)

    sorted = Repository.user_repositories(user.id)
            |> Repository.sort
    assert hd(Repo.all(sorted)) == enabled_repo
  end

  test "finds repositories with out certain ids" do
    user = Pullhub.User.find_or_create(%{email: "jd@testemail.com"})

    first_repo = %{remote_id: 11, name: "t", owner: "1", user_id: user.id}
    |> Repository.find_or_create

    second_repo = %{remote_id: 12, name: "t", owner: "1", user_id: user.id}
    |> Repository.find_or_create

    third_repo = %{remote_id: 13, name: "t", owner: "1", user_id: user.id}
    |> Repository.find_or_create


    query = Repository.without_ids([first_repo.id, second_repo.id])
    assert Pullhub.Repo.all(query) == [third_repo]
  end
end
