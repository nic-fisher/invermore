defmodule Invermore.Game do
  use GenServer, restart: :transient

  @directions [:left, :right, :up, :down]

  # Client API

  def start_link(live_view_pid) do
    GenServer.start_link(__MODULE__, live_view_pid)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def move_icon(pid, direction) when direction in @directions do
    GenServer.call(pid, {:move_icon, direction})
  end

  # Server Callbacks

  def init(live_view_pid) do
    {:ok, %Invermore.Game.State{live_view_pid: live_view_pid},
     {:continue, :start_creating_obstacles}}
  end

  def handle_continue(:start_creating_obstacles, state) do
    Process.send_after(self(), :create_obstacle, 3000)
    {:noreply, state}
  end

  def handle_info(:create_obstacle, state) do
    updated_state = Invermore.Game.Obstacle.create(state)
    send_updated_state_to_live_view(updated_state)

    {:noreply, valid_movement(updated_state)}
  end

  def handle_info({:continue_icon_movement, direction}, state) do
    updated_state = Invermore.Game.Icon.continue_movement(direction, state)
    send_updated_state_to_live_view(updated_state)

    {:noreply, valid_movement(updated_state)}
  end

  def handle_info({:move_obstacle, id}, state) do
    updated_state = Invermore.Game.Obstacle.move(id, state)
    send_updated_state_to_live_view(updated_state)

    {:noreply, valid_movement(updated_state)}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:move_icon, direction}, _from, state) do
    updated_state =
      direction
      |> Invermore.Game.Icon.move(state)
      |> valid_movement()

    {:reply, updated_state, updated_state}
  end

  defp send_updated_state_to_live_view(%{live_view_pid: live_view_pid} = state) do
    send(live_view_pid, %{action: "update_state", state: state})
  end

  defp valid_movement(state) do
    invalid = Enum.any?(state.obstacles, fn obstacle ->
      top_distance = obstacle.top - state.top
      left_distance = obstacle.left - state.left

      invalid_distances(top_distance, left_distance)
    end)

    %{state | game_over: invalid}
  end

  defp invalid_distances(top_distance, left_distance) when top_distance in -15..15 and left_distance in -15..15,
    do: true

  defp invalid_distances(_, _), do: false
end
