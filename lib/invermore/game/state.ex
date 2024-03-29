defmodule Invermore.Game.State do
  alias Invermore.Game.Size

  defstruct left: 338,
            top: 200,
            max_left: Size.max_left(),
            max_top: Size.max_top(),
            moving_direction: nil,
            obstacles: [],
            obstacle_speed: 5,
            prizes: [],
            live_view_pid: nil,
            game_over: false,
            restarting_game: false,
            difficulty_level: "easy",
            score: 0

  defmodule Obstacle do
    defstruct id: nil,
              left: nil,
              top: nil,
              max_left: Size.max_left(),
              max_top: Size.max_top(),
              moving_direction: nil,
              image_src: nil
  end

  defmodule Prize do
    defstruct id: nil,
              left: nil,
              top: nil,
              max_left: Size.max_left(),
              max_top: Size.max_top(),
              removing: false
  end
end
