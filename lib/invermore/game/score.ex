defmodule Invermore.Game.Score do
  alias Invermore.Game.State

  @increase_amount 1

  @doc """
  increase/1
  Updates the state score by @increase_amount, sends an "increase_score" message to the process after 500
  and returns the updated state.
  """
  @spec increase(%State{}) :: %State{}
  def increase(%{game_over: true} = state), do: state

  def increase(%{score: score} = state) do
    updated_state = %{state | score: score + @increase_amount}
    Process.send_after(self(), :increase_score, 500)

    updated_state
  end
end
