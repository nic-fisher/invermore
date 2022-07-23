defmodule Invermore.Game.Manager do
  @moduledoc """
  This module is a connection between the LiveView and the Game Genserver. It handles all user actions
  and starting the game.
  """

  require Logger

  @doc """
  move/1

  - Converts the key to a direction atom
  - Gets the current state
  - If the current state moving direction doesn't equal the new direction, it will:
    1. Call move in the Game Genserver to update the state
    2. Get the updated state
    3. Send a "continue_movement" message to the current process, which is handled in GameLiveView
    4. Return the updated state
  - If the current state moving direction equals the new direction, it will simply return the current state
  """

  @available_keys ["ArrowRight", "ArrowLeft", "ArrowUp", "ArrowDown"]
  @available_directions [:right, :left, :up, :down]

  @spec move(pid(), String.t()) :: %Invermore.Game.State{}
  def move(pid, key_pressed) when key_pressed in @available_keys do
    direction = convert_key_to_direction(key_pressed)
    Invermore.Game.move_icon(pid, direction)

    # current_state = Invermore.Game.get_state(pid)

    # if current_state.moving_direction != direction do
    #   move_in_direction(pid, direction)
    # else
    #   current_state
    # end
  end

  def move(pid, _key_pressed), do: Invermore.Game.get_state(pid)

  @doc """
  continue_movement/2

  - Gets the current state
  - If the current state moving direction equals the direction, it will:
    1. Call move in the Game Genserver to update the state
    2. Get the updated state
    3. Send a "continue_movement" message to the current process, which is handled in GameLiveView
    4. Return the updated state
  - If the current state moving direction doesn't equal the direction passed in, it will simply return the current state
  """

  @spec continue_movement(pid(), String.t()) :: %Invermore.Game.State{}
  def continue_movement(pid, direction) when direction in @available_directions do
    current_state = Invermore.Game.get_state(pid)

    if current_state.moving_direction == direction do
      move_in_direction(pid, direction)
    else
      current_state
    end
  end

  def continue_movement(pid, _direction), do: Invermore.Game.get_state(pid)

  @doc """
  start_game/0

  Creates the game and links it to the live view process.
  """
  @spec start_game() :: {:ok, pid(), pid()} | {:error, String.t()}
  def start_game() do
    with {:ok, game_pid} <- DynamicSupervisor.start_child(Invermore.Game.Supervisor, {Invermore.Game, self()}),
          true <- Process.link(game_pid) do
      create_obstacle()
      {:ok, game_pid}
    else
      _ -> {:error, "Unable to start game"}
    end
  end

  def create_obstacle() do
    Process.send_after(self(), %{action: "create_obstacle"}, 3000)
  end

  def create_obstacle(pid) do
    updated_state = Invermore.Game.create_obstacle(pid)
    create_obstacle()
    updated_state
    # Process.send_after(self(), %{action: "create_obstacle"}, 3000)
  end

  defp move_in_direction(pid, direction) do
    state = Invermore.Game.move_icon(pid, direction)
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
