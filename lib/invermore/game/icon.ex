defmodule Invermore.Game.Icon do
  alias Invermore.Game.State
  @speed 10


  @doc """
  move/1

  - If the current state moving direction doesn't equal the new direction, it will:
    1. Calculate the new icon position and update the state
    2. Send a continue_icon_movement message to the process after 100 milliseconds
    3. Return the updated state
  - If the current state moving direction equals the new direction, it will return the current state
  """
  @spec move(atom(), %State{}) :: %State{}
  def move(direction, state) do
    if state.moving_direction != direction do
      updated_state = move_in_direction(direction, state)
      Process.send_after(self(), {:continue_icon_movement, direction}, 100)
      updated_state
    else
      state
    end
  end

  @doc """
  continue_movement/2
  - If the current state moving direction equals the direction, it will:
    1. Calculate the new icon position and update the state
    3. Send a "continue_icon_movement" message to the process after 100
    4. Return the updated state
  - If the current state moving direction doesn't equal the direction passed in, it will return the current state
  """
  @spec continue_movement(atom(), %State{}) :: %State{}
  def continue_movement(direction, state) do
    if state.moving_direction == direction do
      updated_state = move_in_direction(direction, state)
      Process.send_after(self(), {:continue_icon_movement, direction}, 100)
      updated_state
    else
      state
    end
  end

  defp move_in_direction(:right, state) do
    new_position = calculate_move(:positive, state.left, state.max_left)
    %{state | left: new_position, moving_direction: :right}
  end

  defp move_in_direction(:left, state) do
    new_position = calculate_move(:negative, state.left)
    %{state | left: new_position, moving_direction: :left}
  end

  defp move_in_direction(:up, state) do
    new_position = calculate_move(:negative, state.top)
    %{state | top: new_position, moving_direction: :up}
  end

  defp move_in_direction(:down, state) do
    new_position = calculate_move(:positive, state.top, state.max_top)
    %{state | top: new_position, moving_direction: :down}
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
