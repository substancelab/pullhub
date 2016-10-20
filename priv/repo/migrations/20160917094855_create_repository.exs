defmodule Pullhub.Repo.Migrations.CreateRepository do
  use Ecto.Migration

  def change do
    create table(:repositories) do
      add :name, :string
      add :remote_id, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:repositories, [:user_id])

  end
end
