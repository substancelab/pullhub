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
  def find_or_create(%Pullhub.Repository{} = repository) do
    query = from r in Pullhub.Repository,
            where: r.remote_id == ^repository.remote_id and r.user_id == ^repository.user_id
    if !Repo.one(query)  do
      Repo.insert(repository)
    end
    Repo.one(query)
  end

  def find_or_create(repository) do
    struct(Pullhub.Repository, repository)
    |> find_or_create
  end

  def sort(query) do
    from( r in query,
      order_by: [desc: :enabled, asc: :name]
    )
  end

  def sorted_user_repositories(user_id) do
    user_repositories(Pullhub.Repository, user_id)
    |> sort
  end

  @doc """
  Finds repositories belonging to user with id = user_id
  """
  def user_repositories(user_id) do
    user_repositories(Pullhub.Repository, user_id)
  end

  def user_repositories(query, user_id) do
    from( r in Pullhub.Repository,
          where: r.user_id == ^user_id
        )
  end

  def without_ids(repo_ids) do
    without_ids(Pullhub.Repository, repo_ids)
  end

  def without_ids(query, repo_ids) do
    from( r in query,
          where: not(r.id in ^repo_ids)
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

  def disable_all_user_repositories(user_id, repository_ids_to_enable) do
    user_id
    |> user_repositories
    |> enabled_repositories
    |> without_ids(repository_ids_to_enable)
    |> Repo.update_all(set: [enabled: false])
  end

  def enable_user_repositories(user_id, repository_ids) do
    repository_ids
    |> find_by_ids
    |> Repo.update_all(set: [enabled: true])

    {:ok, Repo.aggregate(find_by_ids(repository_ids), :count, :id)}
  end
end
