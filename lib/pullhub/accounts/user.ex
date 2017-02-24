defmodule Pullhub.User do
  use Pullhub.Web, :model

  alias Pullhub.Repo

  schema "users" do
    field :email, :string
    field :uid, :string
    field :github_token, :string

    has_many :repositories, Pullhub.Repository

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :github_token])
    |> validate_required([:email, :github_token])
  end
end
