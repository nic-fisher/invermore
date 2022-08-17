defmodule Invermore.Game.Validator do
  def valid_movement(state) do
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
