defmodule Invermore.Game do
  use GenServer

  @directions ["left", "right", "up", "down"]

  defmodule State do
    defstruct left: nil, top: nil, max_left: nil, max_top: nil
  end

  ## Client API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  def move(direction) when direction in @directions do
    GenServer.call(__MODULE__, :"move_#{direction}")
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %State{left: 340, top: 190, max_left: 680, max_top: 380}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:move_right, _from, state) do
    new_position = calculate_move(:positive, state.left, state.max_left)
    {:reply, :ok, %{state | left: new_position}}
  end

  def handle_call(:move_left, _from, state) do
    new_position = calculate_move(:negative, state.left)
    {:reply, :ok, %{state | left: new_position}}
  end

  def handle_call(:move_up, _from, state) do
    new_position = calculate_move(:negative, state.top)
    {:reply, :ok, %{state | top: new_position}}
  end

  def handle_call(:move_down, _from, state) do
    new_position = calculate_move(:positive, state.top, state.max_top)
    {:reply, :ok, %{state | top: new_position}}
  end

  defp calculate_move(:positive, position, max) when position >= max do
    position
  end

  defp calculate_move(:positive, position, max) do
    new_position = position + 25

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
    new_position = position - 25

    if new_position > 0 do
      new_position
    else
      0
    end
  end
end
