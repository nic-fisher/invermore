defmodule Invermore.Game.Score do
  alias Invermore.Game.State

  @increase_amount 1
  @increase_obstacle_frequency 10
  @max_obstacle_speed 8
  @increase_obstacle_speed_frequency 20

  @doc """
  increase/1
  Updates the state score by @increase_amount, sends a "create_obstacle" message if divisible by @increase_obstacle_frequency,
  sends an "increase_score" message to the process after 500 and returns the updated state.
  """

  @spec increase(%State{}) :: %State{}
  def increase(%{game_over: true} = state), do: state

  def increase(%{score: score} = state) do
    updated_state = %{state | score: score + @increase_amount}
    increase_obstacles(updated_state.score)
    updated_state = increase_obstacle_speed(updated_state)
    Process.send_after(self(), :increase_score, 500)
    updated_state
  end

  @doc """
  increase_score_by/2
  Increases the score by the amount provided
  """

  @spec increase_score_by(Integer.t(), %State{}) :: %State{}
  def increase_score_by(amount, %{score: score} = state) do
    %{state | score: score + amount}
  end

  defp increase_obstacles(score) when rem(score, @increase_obstacle_frequency) == 0 do
    send(self(), :create_obstacle)
  end

  defp increase_obstacles(_score), do: nil

  defp increase_obstacle_speed(%State{obstacle_speed: obstacle_speed} = state)
       when obstacle_speed >= @max_obstacle_speed,
       do: state

  defp increase_obstacle_speed(%State{score: score, obstacle_speed: obstacle_speed} = state)
       when rem(score, @increase_obstacle_speed_frequency) == 0 do
    %{state | obstacle_speed: obstacle_speed + 1}
  end

  defp increase_obstacle_speed(state), do: state
end
