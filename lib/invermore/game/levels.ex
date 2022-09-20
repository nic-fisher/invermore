defmodule Invermore.Game.Levels do
  @moduledoc """
  This module holds all the values that adjust the difficulty of the game.

  All values will be used as milliseconds.
  """
  @easy "easy"
  @medium "medium"
  @hard "hard"
  @available_levels [@easy, @medium, @hard]

  def easy, do: @easy
  def medium, do: @medium
  def hard, do: @hard
  def available_levels, do: @available_levels

  def create_obstacle_time(@easy), do: 3000
  def create_obstacle_time(@medium), do: 2000
  def create_obstacle_time(@hard), do: 1000

  def create_prize_time(@easy), do: 4000
  def create_prize_time(@medium), do: 5000
  def create_prize_time(@hard), do: 6000

  def start_removing_prize_time(@easy), do: 3000
  def start_removing_prize_time(@medium), do: 2000
  def start_removing_prize_time(@hard), do: 1000

  def remove_prize_time(@easy), do: 10000
  def remove_prize_time(@medium), do: 7000
  def remove_prize_time(@hard), do: 4000

  def increase_score_time(@easy), do: 1000
  def increase_score_time(@medium), do: 1000
  def increase_score_time(@hard), do: 1000

  # This will be used to increase the obstacles anytime the score is divisible by the number
  def increase_obstacle_frequency(@easy), do: 10
  def increase_obstacle_frequency(@medium), do: 5
  def increase_obstacle_frequency(@hard), do: 2
end
