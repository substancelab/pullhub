defmodule Pullhub.Repository do
  use Pullhub.Web, :model

  schema "repositories" do
    field :name, :string
    field :owner, :string
    field :remote_id, :integer
    field :enabled, :boolean
    belongs_to :user, Pullhub.User
    has_many :pull_requests, Pullhub.PullRequest
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :owner, :remote_id, :enabled])
    |> validate_required([:remote_id])
  end
end
