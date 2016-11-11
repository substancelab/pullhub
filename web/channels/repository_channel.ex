defmodule Pullhub.RepositoryChannel do
  use Phoenix.Channel

  def join("repository:list:" <> user_id, _message, socket) do
    {user_id, _} = Integer.parse(user_id)

    %{id: id} = socket.assigns[:user]

    case id == user_id do
    true ->
      {:ok, socket}
    false ->
      {:error, "This is not your solo channel!"}
    end
  end

  def join("repository:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("update_repositories", %{}, socket) do
    %{id: user_id} = socket.assigns[:user]

    Pullhub.RepoFetcher.fetch(%{user: Pullhub.Repo.get!(Pullhub.User, user_id)})
    {:noreply, socket}
  end
end
