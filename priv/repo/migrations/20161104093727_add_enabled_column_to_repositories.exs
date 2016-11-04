defmodule Pullhub.Repo.Migrations.AddEnabledColumnToRepositories do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      add :enabled, :boolean
    end
  end
end
