defmodule Invermore.Game.Validator do
  alias Invermore.Game.State

  @doc """
  validate_movement/1

  - Checks to see if the icon is coliding with any obstacles. If so, it will update the game_over field to true
  - Checks to see if the icon is coliding with any prizes. If so, it will send a message to itself to update the score,
    and remove the prize from the prizes list.
  """

  @spec validate_movement(%State{}) :: %State{}
  def validate_movement(%{game_over: true} = state), do: state
  def validate_movement(state) do
    state = validate_icon_and_obstacles(state)
    state = validate_icon_and_prizes(state)

    state
  end

  defp validate_icon_and_obstacles(state) do
    invalid = Enum.any?(state.obstacles, fn obstacle ->
      top_distance = obstacle.top - state.top
      left_distance = obstacle.left - state.left

      items_touching?(top_distance, left_distance)
    end)

    %{state | game_over: invalid}
  end

  defp validate_icon_and_prizes(state) do
    {collected_prizes, remaining_prizes} =
      Enum.split_with(state.prizes, fn prizes ->
        top_distance = prizes.top - state.top
        left_distance = prizes.left - state.left

        items_touching?(top_distance, left_distance)
      end)

    Enum.each(collected_prizes, fn _prize ->
      send(self(), {:increase_score_by, 100})
    end)

    %{state | prizes: remaining_prizes}
  end

  defp items_touching?(top_distance, left_distance) when top_distance in -15..15 and left_distance in -15..15,
    do: true

  defp items_touching?(_, _), do: false
end
