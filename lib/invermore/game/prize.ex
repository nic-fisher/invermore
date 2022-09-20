defmodule Invermore.Game.Prize do
  alias Invermore.Game.{State, State.Prize, Size, Levels}
  @doc """
  create/1

  - creates a new prize,
  - Sends a message to itself to start removing prize
  - Sends a message to itself to create a new prize
  - Returns updated the state with new prize added to the prize list
  """
  @spec create(%State{}) :: %State{}
  def create(%{game_over: true} = state), do: state
  def create(%{difficulty_level: difficulty_level} = state) do
    new_prize = %Prize{
      id: Ecto.UUID.generate(),
      left: Enum.random(0..Size.max_left()),
      top: Enum.random(0..Size.max_top())
    }

    Process.send_after(self(), {:start_removing_prize, new_prize.id}, Levels.start_removing_prize_time(difficulty_level))
    Process.send_after(self(), :create_prize, Levels.create_prize_time(difficulty_level))

    %{state | prizes: [new_prize | state.prizes]}
  end

  @doc """
  start_removing_prize/2

  - Updated the removing field on the prize to true
  - Sends a message to itself to remove the prize
  - Returns updated the state with the new prize list
  """
  @spec start_removing_prize(String.t(), %State{}) :: %State{}
  def start_removing_prize(_id, %{game_over: true} = state), do: state
  def start_removing_prize(id, %{difficulty_level: difficulty_level} = state) do
    updated_prizes = Enum.reduce(state.prizes, [], fn prize, acc ->
      if prize.id == id do
        [%{prize | removing: true} | acc]
      else
        [prize | acc]
      end
    end)

    Process.send_after(self(), {:remove_prize, id}, Levels.remove_prize_time(difficulty_level))

    %{state | prizes: updated_prizes}
  end

  @doc """
  remove_prize/2

  - Removes the prize that matches the id from the prizes list
  - Returns updated the state with the new prize list
  """
  def remove_prize(_id, %{game_over: true} = state), do: state
  def remove_prize(id, state) do
    updated_prizes = Enum.reduce(state.prizes, [], fn prize, acc ->
      if prize.id == id do
        acc
      else
        [prize | acc]
      end
    end)

    %{state | prizes: updated_prizes}
  end
end
