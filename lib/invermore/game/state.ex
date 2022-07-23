defmodule Invermore.Game.State do
  defstruct left: 340, top: 190, max_left: 680, max_top: 380, moving_direction: nil, obstacles: [], live_view_pid: nil

  defmodule Obstacle do
    defstruct id: nil, left: nil, top: nil, max_left: 680, max_top: 380, moving_direction: nil
  end
end
