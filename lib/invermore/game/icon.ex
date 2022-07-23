defmodule Invermore.Game.Icon do
  @speed 10

  # this module should:
  # check current state if the icon is already moving in the direction provided
  # If so, return the current state
  # If not, move the icon, update the moving direction, send message to process to continue movement and return updated state

  # move(direction, state) :: updated_state
  def move(direction, state) do
    if state.moving_direction != direction do
      updated_state = move_in_direction(direction, state)
      Process.send_after(self(), {:continue_icon_movement, direction}, 100)
      updated_state
    else
      state
    end
  end

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
