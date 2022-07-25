defmodule Invermore.Game.Obstacle do
  @speed 6

  # create(state) :: {obstacle_id, updated_state}
  def create(state) do
    moving_direction = Enum.random([:left, :right, :up, :down])
    {left, top} = starting_position(moving_direction)

    new_obstacle = %Invermore.Game.State.Obstacle{id: Ecto.UUID.generate, left: left, top: top, moving_direction: moving_direction}

    {new_obstacle.id, %{state | obstacles: [new_obstacle | state.obstacles]}}
  end

  def move(id, state) do
    {status, obstacles} =
      Enum.reduce(state.obstacles, {:ok, []}, fn obstacle, {status, list} ->
        if obstacle.id == id do
          case move_in_direction(obstacle.moving_direction, obstacle) do
            {:remove_obstacle, _} -> {:remove_obstacle, [nil | list]}
            {:ok, updated_obstacle} -> {status, [updated_obstacle | list]}
          end
        else
          {status, [obstacle | list]}
        end
      end)

    obstacles = Enum.reject(obstacles, &is_nil/1)

    {status, %{state | obstacles: obstacles}}
  end

  defp starting_position(:left), do: {680, Enum.random(0..380)}
  defp starting_position(:right), do: {0, Enum.random(0..380)}
  defp starting_position(:up), do: {Enum.random(0..680), 380}
  defp starting_position(:down), do: {Enum.random(0..680), 0}

  defp move_in_direction(:right, obstacle_state) do
    {status, new_position} = calculate_move(:positive, obstacle_state.left, obstacle_state.max_left)
    {status, %{obstacle_state | left: new_position}}
  end

  defp move_in_direction(:left, obstacle_state) do
    {status, new_position} = calculate_move(:negative, obstacle_state.left)
    {status, %{obstacle_state | left: new_position}}
  end

  defp move_in_direction(:up, obstacle_state) do
    {status, new_position}  = calculate_move(:negative, obstacle_state.top)
    {status, %{obstacle_state | top: new_position}}
  end

  defp move_in_direction(:down, obstacle_state) do
    {status, new_position} = calculate_move(:positive, obstacle_state.top, obstacle_state.max_top)
    {status, %{obstacle_state | top: new_position}}
  end

  defp calculate_move(:positive, position, max) when position >= max do
    {:ok, position}
  end

  defp calculate_move(:positive, position, max) do
    new_position = position + @speed

    if new_position < max do
      {:ok, new_position}
    else
      {:remove_obstacle, max}
    end
  end

  defp calculate_move(:negative, position) when position == 0 do
    {:ok, position}
  end

  defp calculate_move(:negative, position) do
    new_position = position - @speed

    if new_position > 0 do
      {:ok, new_position}
    else
      {:remove_obstacle, 0}
    end
  end
end
