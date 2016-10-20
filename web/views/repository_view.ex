defmodule Pullhub.RepositoryView do
  use Pullhub.Web, :view

  def user_has_repo_checked(user_repos, repository) do
    Enum.find(user_repos, fn(r) -> r.remote_id == repository.id end) != nil
  end


end
