defmodule Invermore.Game do
  use GenServer, restart: :transient

  @directions [:left, :right, :up, :down]

  ## Client API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def move(pid, direction) when direction in @directions do
    GenServer.call(pid, :"move_#{direction}")
  end

  def poll(pid) do
    GenServer.cast(pid, :poll)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %Invermore.Game.State{}, {:continue, :monitor_polling}}
  end

  def handle_continue(:monitor_polling, state) do
    Process.send_after(self(), :monitor_polling, 11000)
    {:noreply, state}
  end

  def handle_info(:monitor_polling, state) do
    if DateTime.diff(DateTime.utc_now(), state.last_polled_at, :seconds) < 10 do
      Process.send_after(self(), :monitor_polling, 2000)

      {:noreply, state}
    else
      {:stop, :normal, state}
    end
  end

  def handle_cast(:poll, state) do
    {:noreply, %{state | last_polled_at: DateTime.utc_now()}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:move_right, _from, state) do
    new_position = calculate_move(:positive, state.left, state.max_left)
    {:reply, :ok, %{state | left: new_position, moving_direction: :right}}
  end

  def handle_call(:move_left, _from, state) do
    new_position = calculate_move(:negative, state.left)
    {:reply, :ok, %{state | left: new_position, moving_direction: :left}}
  end

  def handle_call(:move_up, _from, state) do
    new_position = calculate_move(:negative, state.top)
    {:reply, :ok, %{state | top: new_position, moving_direction: :up}}
  end

  def handle_call(:move_down, _from, state) do
    new_position = calculate_move(:positive, state.top, state.max_top)
    {:reply, :ok, %{state | top: new_position, moving_direction: :down}}
  end

  defp calculate_move(:positive, position, max) when position >= max do
    position
  end

  defp calculate_move(:positive, position, max) do
    new_position = position + 15

    if new_position < max do
      new_position
    else
      max
    end
  end

  defp calculate_move(:negative, position) when position == 0 do
    position
  end

  defp calculate_move(:negative, position) do
    new_position = position - 15

    if new_position > 0 do
      new_position
    else
      0
    end
  end
end
