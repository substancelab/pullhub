defmodule Pullhub.Accounts do

  alias Pullhub.Repo
  alias Pullhub.User
  import Ecto
  import Ecto.Query

  @doc """
  Finds one user based on email. If none is found it is created and returned
  """
  def find_or_create(%User{} = user) do
    query = from u in User,
            where: u.email == ^user.email
    if !Repo.one(query)  do
      Repo.insert(user)
    else
      Repo.update_all(query, set: [github_token: user.github_token, uid: user.uid])
    end
    Repo.one(query)
  end

  def find_by_id!(user_id) do
    Repo.get!(User, user_id)
  end

  def find_or_create(user) do
    struct(User, user)
    |> find_or_create
  end

  def users_with_github_tokens do
    (from user in User, where: not(is_nil(user.github_token)))
    |> Repo.all
  end
end
