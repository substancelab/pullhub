defmodule UserFromAuth do
  require Logger
  @moduledoc """
  Retrieve the user information from an auth request
  """

  alias Pullhub.User
  alias Ueberauth.Auth

  def find_or_create(%Auth{provider: :identity} = auth) do
    Logger.debug "auth.credentials: #{auth.credentials}"
    case validate_pass(auth.credentials) do
      :ok ->
        {:ok, basic_info(auth)}
      {:error, reason} -> {:error, reason}
    end
  end

  def find_or_create(%Auth{} = auth) do
    Logger.debug "auth: #{auth.credentials.token}"
    Logger.debug "auth: #{auth.info.email}"

    %User{email: auth.info.email, github_token: auth.credentials.token }
    |> User.find_or_create
    |> return_ok
  end



  def return_ok(user) do
    {:ok, user}
  end

  defp basic_info(auth) do
    %{
      id: auth.uid,
      name: name_from_auth(auth),
      avatar: auth.info.image,
      token: auth.credentials.token
    }
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name = [auth.info.first_name, auth.info.last_name]
      |> Enum.filter(&(&1 != nil and &1 != ""))

      cond do
        length(name) == 0 -> auth.info.nickname
        true -> Enum.join(name, " ")
      end
    end
  end

  defp validate_pass(%{other: %{password: ""}}) do
    {:error, "Password required"}
  end
  defp validate_pass(%{other: %{password: pw, password_confirmation: pw}}) do
    :ok
  end
  defp validate_pass(%{other: %{password: _}}) do
    {:error, "Passwords do not match"}
  end
  defp validate_pass(_), do: {:error, "Password Required"}
end