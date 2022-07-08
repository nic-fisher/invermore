defmodule Invermore.Game.Monitor do
  use GenServer, restart: :transient

  @live_view_polling_frequency_ms 2000
  @monitor_polling_frequency_ms 1000
  @max_time_seconds 5000

  @doc """
  This process monitors the connection between the LiveView process and the game process.
  It will continue to receive messages from the LiveView process and if it stops receiving messages,
  it will stop itself and the game process.
  """

  # Constants

  def live_view_polling_frequency_ms, do: @live_view_polling_frequency_ms
  def monitor_polling_frequency_ms, do: @monitor_polling_frequency_ms

  # API Client

  def start_link(game_pid) do
    GenServer.start_link(__MODULE__, game_pid)
  end

  def poll(pid) do
    GenServer.cast(pid, :poll)
  end

  # Server Callbacks

  def init(game_pid) do
    {:ok,
     %Invermore.Game.Monitor.State{last_polled_at: DateTime.utc_now(), pid_monitoring: game_pid},
     {:continue, :start_monitoring}}
  end

  def handle_continue(:start_monitoring, state) do
    Process.send_after(self(), :monitor_polling, @monitor_polling_frequency_ms)
    {:noreply, state}
  end

  def handle_info(:monitor_polling, state) do
    if DateTime.diff(DateTime.utc_now(), state.last_polled_at, :millisecond) < @max_time_seconds do
      Process.send_after(self(), :monitor_polling, @monitor_polling_frequency_ms)

      {:noreply, state}
    else
      Process.send(state.pid_monitoring, :stop, [:noconnect])
      {:stop, :normal, state}
    end
  end

  def handle_cast(:poll, state) do
    {:noreply, %{state | last_polled_at: DateTime.utc_now()}}
  end
end
