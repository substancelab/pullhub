defmodule Pullhub.Repo do
  use Ecto.Repo, otp_app: :pullhub

  def count(query), do: aggregate(query, :count, :id)
end
