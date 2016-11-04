defmodule Pullhub.PullRequestTest do
  use Pullhub.ModelCase

  alias Pullhub.PullRequest

  @valid_attrs %{body: "some content", issue_url: "some content", remote_id: 42, state: "some content", title: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PullRequest.changeset(%PullRequest{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PullRequest.changeset(%PullRequest{}, @invalid_attrs)
    refute changeset.valid?
  end
end
