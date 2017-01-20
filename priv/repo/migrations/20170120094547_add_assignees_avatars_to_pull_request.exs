defmodule Pullhub.Repo.Migrations.AddAssigneesAvatarsToPullRequest do
  use Ecto.Migration

  def change do
    alter table(:pull_requests) do
      add :assignees_avatars, {:array, :string}
    end
  end
end
