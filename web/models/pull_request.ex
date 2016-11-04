defmodule Pullhub.PullRequest do
  use Pullhub.Web, :model

  schema "pull_requests" do
    field :title, :string
    field :body, :string
    field :remote_id, :integer
    field :author_login, :string
    field :assignees_logins, {:array, :string}
    field :state, :string
    field :issue_url, :string
    field :url, :string
    belongs_to :repository, Pullhub.Repository
    belongs_to :author, Pullhub.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body, :assignees_logins, :author_login, :remote_id, :state, :issue_url, :url, :repository_id])
    |> validate_required([:title, :body, :remote_id, :state, :issue_url, :url])
  end

  def open_pull_requests do
    from(p in Pullhub.PullRequest, where: p.state == "open")
  end
end
