defmodule Pullhub.PullRequestChannel do
  use Phoenix.Channel

  def join("pull_request:" <> user_id, _message, socket) do
    {user_id, _} = Integer.parse(user_id)

    %{id: id} = socket.assigns[:user]

    case id == user_id do
    true ->
      {:ok, socket}
    false ->
      {:error, "This is not your solo channel!"}
    end
  end

  def handle_in("update_pull_requests", %{}, socket) do
    %{id: user_id} = socket.assigns[:user]

    %{user: Pullhub.Accounts.find_by_id!(user_id)}
    |> Pullhub.PullRequestsFetcher.fetch

    {:noreply, socket}
  end
end
