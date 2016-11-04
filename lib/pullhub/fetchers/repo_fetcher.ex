defmodule Pullhub.RepoFetcher do
  require Logger

  use GenServer

  alias Pullhub.Repo
  alias Pullhub.Repository

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    Logger.info("doing work")
    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 5 * 1000) # In 2 hours
  end

end
