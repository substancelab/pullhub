defmodule Pullhub.RepositoryTest do
  use Pullhub.ModelCase

  alias Pullhub.Repository

  @valid_attrs %{name: "some content", remote_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Repository.changeset(%Repository{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Repository.changeset(%Repository{}, @invalid_attrs)
    refute changeset.valid?
  end
end
