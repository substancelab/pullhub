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

  def sort(repositories) do
    Enum.sort(
      repositories, &(
        &1.enabled > &2.enabled
      )
    )
  end

  @doc """
  Finds repositories belonging to user with id = user_id
  """
  def user_repositories(user_id) do
    from( r in Pullhub.Repository,
          where: r.user_id == ^user_id
        )
  end

  def preload_user(query) do
    from( r in query,
        preload: [
          user: :repositories
        ]
    )
  end

  @doc """
  Finds repositories marked as enabled
  """
  def enabled_repositories(query) do
    from( r in query,
          where: r.enabled == true
        )
  end

  @doc """
  Finds repositories by a list of ids
  """
  def find_by_ids(repository_ids) do
    from(r in Pullhub.Repository, where: r.id in ^repository_ids)
  end
end
