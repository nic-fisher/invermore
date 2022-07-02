defmodule Invermore.Game.State do
  # @enforce_keys [:left, :top, :max_left, :max_top]

  defstruct left: 340, top: 190, max_left: 680, max_top: 380, moving_direction: nil
end
