defmodule Pullhub.RepositoryControllerTest do
  use Pullhub.ConnCase

  alias Pullhub.User
  @valid_attrs %{name: "some content", remote_id: 42}
  @invalid_attrs %{}

  setup do
    %User{
      id: 123456,
      email: "abc@gmail.com",
    } |> Repo.insert

    {:ok, user: Repo.get(User, 123456) }
  end

  defp session_conn(user) do
    build_conn()
    |> assign(:current_user, user)
  end

  test "lists all entries on index", %{user: user} do
    conn = session_conn(user)
    conn = get conn, repository_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing repositories"
  end
end
