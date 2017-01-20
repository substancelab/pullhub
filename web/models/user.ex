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

  @doc """
  Finds one user based on email. If none is found it is created and returned
  """
  def find_or_create(%Pullhub.User{} = user) do
    query = from u in Pullhub.User,
            where: u.email == ^user.email
    if !Repo.one(query)  do
      Repo.insert(user)
    else
      Repo.update_all(query, set: [github_token: user.github_token, uid: user.uid])
    end
    Repo.one(query)
  end

  def find_or_create(user) do
    struct(Pullhub.User, user)
    |> find_or_create
  end

  def users_with_github_tokens do
    (from user in Pullhub.User, where: not(is_nil(user.github_token)))
    |> Repo.all
  end
end
