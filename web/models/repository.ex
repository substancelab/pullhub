defmodule Pullhub.Repository do
  use Pullhub.Web, :model

  alias Pullhub.Repo

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

  @doc """
  Finds one repository based on remote_id. If none is found it is created and returned
  """
  def find_or_create(repository) do
    query = from r in Pullhub.Repository,
            where: r.remote_id == ^repository.remote_id and r.user_id == ^repository.user_id
    if !Repo.one(query)  do
      Repo.insert(struct(Pullhub.Repository, repository))
    end
    Repo.one(query)
  end

  def user_repositories(user_id) do
    from( r in Pullhub.Repository,
          where: r.user_id == ^user_id
        )
  end

  def enabled_repositories(query) do
    from( r in query,
          where: r.enabled == true
        )
  end

  def find_by_ids(repository_ids) do
    from(r in Repository, where: r.id in ^repository_ids)
  end
end
