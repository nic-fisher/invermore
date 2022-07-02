defmodule Invermore.Game.Manager do
  @moduledoc """
  This module is a connection between the LiveView and the Game Genserver. It handles all user actions.

  These actions are move and continue_movement.

  move/1
  - Converts the key to a direction atom
  - Gets the current state
  - If the current state moving direction doesn't equal the new direction, it will:
    1. Call move in the Game Genserver to update the state
    2. Get the updated state
    3. Send a "continue_movement" message to the current process, which is handled in GameLiveView
    4. Return the updated state
  - If the current state moving direction equals the new direction, it will simply return the current state

  continue_movement/1
  - Gets the current state
  - If the current state moving direction equals the direction, it will:
    1. Call move in the Game Genserver to update the state
    2. Get the updated state
    3. Send a "continue_movement" message to the current process, which is handled in GameLiveView
    4. Return the updated state
  - If the current state moving direction doesn't equal the direction passed in, it will simply return the current state
  """

  @available_keys ["ArrowRight", "ArrowLeft", "ArrowUp", "ArrowDown"]
  @available_directions [:right, :left, :up, :down]

  @spec move(String.t()) :: %Invermore.Game.State{}
  def move(key_pressed) when key_pressed in @available_keys do
    direction = convert_key_to_direction(key_pressed)
    current_state = Invermore.Game.get_state()

    if current_state.moving_direction != direction do
      move_in_direction(direction)
    else
      current_state
    end
  end

  def move(_key_pressed), do: Invermore.Game.get_state()

  @spec continue_movement(String.t()) :: %Invermore.Game.State{}
  def continue_movement(direction) when direction in @available_directions do
    current_state = Invermore.Game.get_state()

    if current_state.moving_direction == direction do
      move_in_direction(direction)
    else
      current_state
    end
  end

  def continue_movement(_), do: Invermore.Game.get_state()

  defp move_in_direction(direction) do
    Invermore.Game.move(direction)
    state = Invermore.Game.get_state()
    Process.send_after(self(), %{action: "continue_movement", direction: direction }, 100)
    state
  end

  defp convert_key_to_direction(key_pressed) do
    moves = %{
      "ArrowRight" => :right,
      "ArrowLeft" => :left,
      "ArrowUp" => :up,
      "ArrowDown" => :down,
    }

    Map.get(moves, key_pressed)
  end
end
