defmodule Invermore.Game.Manager do
  alias Invermore.Game.Levels
  @moduledoc """
  This module is a connection between the LiveView and the Game Genserver. It handles all user actions
  and starting the game.
  """

  @available_keys ["ArrowRight", "ArrowLeft", "ArrowUp", "ArrowDown"]
  @available_levels Levels.available_levels

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
  @spec start_game(String.t()) :: {:ok, pid()} | {:error, String.t()}
  def start_game(difficulty_level) do
    with {:ok, game_pid} <-
           DynamicSupervisor.start_child(Invermore.Game.Supervisor, {Invermore.Game, [self(), difficulty_level]}),
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

  @spec complete_game_restart(pid()) :: %Invermore.Game.State{}
  def complete_game_restart(pid) do
    Invermore.Game.complete_game_restart(pid)
  end

  @spec update_difficulty_level(pid(), String.t()) :: %Invermore.Game.State{}
  def update_difficulty_level(pid, level) when level in @available_levels do
    Invermore.Game.update_difficulty_level(pid, level)
  end

  def update_difficulty_level(pid, _level), do: Invermore.Game.get_state(pid)

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
