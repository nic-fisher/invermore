defmodule Invermore.Game.Obstacle do
  alias Invermore.Game.{Size, State}

  @speed 6

  @doc """
  create/1
  Creates a new obstacle and adds it to the obstacles list in the state
  """
  @spec create(%State{}) :: %State{}
  def create(%{game_over: true} = state), do: state

  def create(state) do
    moving_direction = Enum.random([:left, :right, :up, :down])
    {left, top} = starting_position(moving_direction)

    new_obstacle = %Invermore.Game.State.Obstacle{
      id: Ecto.UUID.generate(),
      left: left,
      top: top,
      moving_direction: moving_direction
    }

    Process.send_after(self(), :create_obstacle, 3000)
    Process.send_after(self(), {:move_obstacle, new_obstacle.id}, 100)

    %{state | obstacles: [new_obstacle | state.obstacles]}
  end

  @doc """
  move/2
  Loops through the list of obstacles and updates the obstacle that matches the id. If
  the obstacle reaches the max_left, max_top or 0, it will remove the obstacle from the
  list. If not, it will send a "move_obstacle" message to the process after 100.
  """
  @spec move(Ecto.UUID.t(), %State{}) :: %State{}
  def move(_id, %{game_over: true} = state), do: state

  def move(id, state) do
    updated_obstacles =
      case update_obstacle_position(id, state.obstacles) do
        {:remove_obstacle, updated_obstacles} ->
          updated_obstacles

        {:ok, updated_obstacles} ->
          Process.send_after(self(), {:move_obstacle, id}, 100)
          updated_obstacles
      end

    %{state | obstacles: updated_obstacles}
  end

  defp starting_position(:left), do: {Size.max_left(), Enum.random(0..Size.max_top())}
  defp starting_position(:right), do: {0, Enum.random(0..Size.max_top())}
  defp starting_position(:up), do: {Enum.random(0..Size.max_left()), Size.max_top()}
  defp starting_position(:down), do: {Enum.random(0..Size.max_left()), 0}

  defp update_obstacle_position(id, obstacles) do
    {status, updated_obstacles} =
      Enum.reduce(obstacles, {:ok, []}, fn obstacle, {status, list} ->
        if obstacle.id == id do
          case move_in_direction(obstacle.moving_direction, obstacle) do
            {:remove_obstacle, _} -> {:remove_obstacle, list}
            {:ok, updated_obstacle} -> {status, [updated_obstacle | list]}
          end
        else
          {status, [obstacle | list]}
        end
      end)

    {status, updated_obstacles}
  end

  defp move_in_direction(:right, obstacle_state) do
    {status, new_position} =
      calculate_move(:positive, obstacle_state.left, obstacle_state.max_left)

    {status, %{obstacle_state | left: new_position}}
  end

  defp move_in_direction(:left, obstacle_state) do
    {status, new_position} = calculate_move(:negative, obstacle_state.left)
    {status, %{obstacle_state | left: new_position}}
  end

  defp move_in_direction(:up, obstacle_state) do
    {status, new_position} = calculate_move(:negative, obstacle_state.top)
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
