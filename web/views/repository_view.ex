defmodule Pullhub.RepositoryView do
  use Pullhub.Web, :view

  def user_has_repo_checked(user_repos, repository) do
    repository.enabled
  end


end
