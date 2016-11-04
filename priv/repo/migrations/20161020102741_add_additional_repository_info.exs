defmodule Pullhub.Repo.Migrations.AddAdditionalRepositoryInfo do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      add :owner, :string
    end
  end
end
