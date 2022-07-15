defmodule Invermore.Game do
  use GenServer, restart: :transient

  @directions [:left, :right, :up, :down]
  @speed 10

  # Client API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def move(pid, direction) when direction in @directions do
    GenServer.call(pid, :"move_#{direction}")
  end

  def create_obstacle(pid) do
    GenServer.call(pid, :create_obstacle)
  end

  # Server Callbacks

  def init(:ok) do
    {:ok, %Invermore.Game.State{}}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:move_right, _from, state) do
    new_position = calculate_move(:positive, state.left, state.max_left)
    updated_state = %{state | left: new_position, moving_direction: :right}
    {:reply, updated_state, updated_state}
  end

  def handle_call(:move_left, _from, state) do
    new_position = calculate_move(:negative, state.left)
    updated_state = %{state | left: new_position, moving_direction: :left}
    {:reply, updated_state, updated_state}
  end

  def handle_call(:move_up, _from, state) do
    new_position = calculate_move(:negative, state.top)
    updated_state = %{state | top: new_position, moving_direction: :up}
    {:reply, updated_state, updated_state}
  end

  def handle_call(:move_down, _from, state) do
    new_position = calculate_move(:positive, state.top, state.max_top)
    updated_state = %{state | top: new_position, moving_direction: :down}
    {:reply, updated_state, updated_state}
  end

  def handle_call(:create_obstacle, _from, state) do
    left = Enum.random(0..680)
    top = Enum.random(0..380)
    new_obstacle = %Invermore.Game.State.Obstacle{left: left, top: top}

    updated_state = %{state | obstacles: [new_obstacle | state.obstacles]}
    {:reply, updated_state, updated_state}
  end

  defp calculate_move(:positive, position, max) when position >= max do
    position
  end

  defp calculate_move(:positive, position, max) do
    new_position = position + @speed

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
    new_position = position - @speed

    if new_position > 0 do
      new_position
    else
      0
    end
  end
end
