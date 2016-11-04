defmodule Pullhub.Repo.Migrations.CreatePullRequest do
  use Ecto.Migration

  def change do
    create table(:pull_requests) do
      add :title, :string
      add :body, :text
      add :author_login, :text
      add :assignees_logins, {:array, :string}
      add :remote_id, :integer
      add :state, :string
      add :issue_url, :string
      add :url, :string
      add :repository_id, references(:repositories, on_delete: :nothing)
      add :author_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:pull_requests, [:repository_id])
    create index(:pull_requests, [:author_id])
    create index(:pull_requests, [:remote_id])
    create index(:pull_requests, [:repository_id, :remote_id])

  end
end
