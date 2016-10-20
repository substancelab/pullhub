defmodule Pullhub.Repository do
  use Pullhub.Web, :model

  schema "repositories" do
    field :name, :string
    field :remote_id, :integer
    belongs_to :user, Pullhub.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :remote_id])
    |> validate_required([:remote_id])
  end
end
