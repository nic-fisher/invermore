defmodule Invermore.GameManager do

  require Logger

  @available_movements ["ArrowRight", "ArrowLeft", "ArrowUp", "ArrowDown"]

  # This function will take a key_pressed (["ArrowRight", "ArrowLeft", "ArrowUp", "ArrowDown"])
  # It will:
  # - convert the key to a direction atom
  # - get the current state
  # - check if the moving direction matches the new direction. If it does, it will just return the current state
  #   because no action is required
  # - If not, it will move the box, send a message to continue moving the move and then return the new state
  def move(key_pressed) when key_pressed in @available_movements do
    direction = convert_key_to_direction(key_pressed)
    current_state = Invermore.Game.get_state()

    if current_state.moving_direction != direction do
      Invermore.Game.move(direction)
      state = Invermore.Game.get_state()
      Process.send_after(self(), %{action: "continue_movement", direction: direction }, 100)
      state
    else
      current_state
    end
  end

  def move(_key_pressed) do
    Invermore.Game.get_state()
  end

  def continue_movement(direction) do
    current_state = Invermore.Game.get_state()

    if current_state.moving_direction == direction do
      Invermore.Game.move(direction)
      updated_state = Invermore.Game.get_state()
      Process.send_after(self(), %{action: "continue_movement", direction: direction }, 100)
      updated_state
    else
      current_state
    end
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
