defmodule Invermore.Game do
  use GenServer, restart: :transient

  @directions [:left, :right, :up, :down]
  @speed 10

  # Things I want to change:
  # Move icon logic into an icon module
  # Move obstacle logic into an obstacle module
  # State will still be managed in Game Server

  # Continue movement will be done in the game process but handled in icon and obstacle modules.
  # Instead of the request coming from the live process. This should be handling the game process

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

  def create_obstacle(pid) do
    GenServer.call(pid, :create_obstacle)
  end

  # Server Callbacks

  def init(live_view_pid) do
    {:ok, %Invermore.Game.State{live_view_pid: live_view_pid}}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_info({:continue_icon_movement, direction}, state) do
    updated_state = Invermore.Game.Icon.continue_movement(direction, state)
    send_updated_state_to_live_view(updated_state)

    {:noreply, updated_state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:move_icon, direction}, _from, state) do
    updated_state = Invermore.Game.Icon.move(direction, state)

    {:reply, updated_state, updated_state}
  end

  def handle_call(:create_obstacle, _from, state) do
    left = Enum.random(0..680)
    top = Enum.random(0..380)
    new_obstacle = %Invermore.Game.State.Obstacle{left: left, top: top}

    updated_state = %{state | obstacles: [new_obstacle | state.obstacles]}
    {:reply, updated_state, updated_state}
  end

  defp send_updated_state_to_live_view(%{live_view_pid: live_view_pid} = state) do
    send(live_view_pid, %{action: "update_state", state: state})
  end
end
