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
    new_repo = %{remote_id: 11, name: "t", owner: "1"}

    assert Pullhub.Repo.get_by(Repository, new_repo) == nil

    Repository.find_or_create(new_repo)
    assert Pullhub.Repo.get_by(Repository, new_repo)
  end

  test "find_or_create returns existing one" do
    new_repo = %{remote_id: 11, name: "t", owner: "1"}
    Repository.find_or_create(new_repo)
    Repository.find_or_create(new_repo)
    assert length(Pullhub.Repo.all(Repository)) == 1
  end

  test "sort sorts the repositories" do
    repo = %{remote_id: 10, name: "aaaalong", owner: "1", enabled: false}
    enabled_repo = %{remote_id: 11, name: "ZZZZebra", owner: "1", enabled: true}
    assert hd(Repository.sort([repo, enabled_repo])) == enabled_repo
  end
end
