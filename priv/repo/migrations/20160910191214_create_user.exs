defmodule Pullhub.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :uid, :string
      add :github_token, :string

      timestamps()
    end

  end
end
