defmodule Pullhub.LayoutView do
  use Pullhub.Web, :view

  def title(conn) do
    [conn.assigns[:page_title], "Pullhub"]
    |> Enum.join(" | ")
  end
end
