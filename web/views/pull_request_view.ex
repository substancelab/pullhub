defmodule Pullhub.PullRequestView do
  use Pullhub.Web, :view

  def mark_if_assigned(pull_request, user) do
    users = Enum.filter(pull_request.assignees_logins,
        fn(assignee) -> assignee == user.uid end)

    if Enum.count(users) > 0 do
      "highlight"
    end
  end
end
