defmodule Invermore.Game.Manager do
  @moduledoc """
  This module is a connection between the LiveView and the Game Genserver. It handles all user actions
  and starting the game.
  """

  @available_keys ["ArrowRight", "ArrowLeft", "ArrowUp", "ArrowDown"]

  @spec move(pid(), String.t()) :: %Invermore.Game.State{}
  def move(pid, key_pressed) when key_pressed in @available_keys do
    direction = convert_key_to_direction(key_pressed)
    Invermore.Game.move_icon(pid, direction)
  end

  def move(pid, _key_pressed), do: Invermore.Game.get_state(pid)

  @doc """
  start_game/0

  Creates the game and links it to the live view process.
  """
  @spec start_game() :: {:ok, pid()} | {:error, String.t()}
  def start_game() do
    with {:ok, game_pid} <-
           DynamicSupervisor.start_child(Invermore.Game.Supervisor, {Invermore.Game, self()}),
         true <- Process.link(game_pid) do
      {:ok, game_pid}
    else
      _ -> {:error, "Unable to start game"}
    end
  end

  @doc """
  restart_game/1

  Resets state to default values except for the live_view_pid.
  """
  @spec restart_game(pid()) :: %Invermore.Game.State{}
  def restart_game(pid) do
    Invermore.Game.restart_game(pid)
  end

  def complete_game_restart(pid) do
    Invermore.Game.complete_game_restart(pid)
  end

  defp convert_key_to_direction(key_pressed) do
    moves = %{
      "ArrowRight" => :right,
      "ArrowLeft" => :left,
      "ArrowUp" => :up,
      "ArrowDown" => :down
    }

    Map.get(moves, key_pressed)
  end
end
