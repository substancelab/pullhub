defmodule Pullhub.Repository do
  use Pullhub.Web, :model

  alias Pullhub.Repo

  schema "repositories" do
    field :name, :string
    field :owner, :string
    field :remote_id, :integer
    belongs_to :user, Pullhub.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :owner, :remote_id])
    |> validate_required([:remote_id])
  end

  @doc """
  Finds one repository based on remote_id. If none is found it is created and returned
  """
  def find_or_create(repository) do
    query = from r in Pullhub.Repository,
            where: r.remote_id == ^repository.remote_id
    if !Repo.one(query)  do
      Repo.insert(struct(Pullhub.Repository, repository))
    end
    Repo.one(query)
  end
end
