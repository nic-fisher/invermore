defmodule Invermore.Game do
  use GenServer, restart: :transient
  alias Invermore.Game.Levels

  @directions [:left, :right, :up, :down]

  # Client API

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def restart_game(pid) do
    GenServer.call(pid, :restart_game)
  end

  def complete_game_restart(pid) do
    GenServer.call(pid, :complete_game_restart)
  end

  def move_icon(pid, direction) when direction in @directions do
    GenServer.call(pid, {:move_icon, direction})
  end

  def update_difficulty_level(pid, level) do
    GenServer.call(pid, {:update_difficulty_level, level})
  end

  # Server Callbacks

  def init([live_view_pid, difficulty_level]) do
    {:ok, %Invermore.Game.State{live_view_pid: live_view_pid, difficulty_level: difficulty_level},
     {:continue, :start_game}}
  end

  def handle_continue(:start_game, %{difficulty_level: difficulty_level} = state) do
    start_game(difficulty_level)
    {:noreply, state}
  end

  # Score Callbacks

  def handle_info(:increase_score, state) do
    updated_state = Invermore.Game.Score.increase(state)
    send_updated_state_to_live_view(updated_state)

    {:noreply, updated_state}
  end

  def handle_info({:increase_score_by, amount}, state) do
    updated_state = Invermore.Game.Score.increase_score_by(amount, state)
    send_updated_state_to_live_view(updated_state)

    {:noreply, updated_state}
  end

  # Prize Callbacks

  def handle_info(:create_prize, state) do
    updated_state = Invermore.Game.Prize.create(state)
    send_updated_state_to_live_view(updated_state)

    {:noreply, valid_movement(updated_state)}
  end

  def handle_info({:start_removing_prize, id}, state) do
    updated_state = Invermore.Game.Prize.start_removing_prize(id, state)
    send_updated_state_to_live_view(updated_state)

    {:noreply, updated_state}
  end

  def handle_info({:remove_prize, id}, state) do
    updated_state = Invermore.Game.Prize.remove_prize(id, state)
    send_updated_state_to_live_view(updated_state)

    {:noreply, updated_state}
  end

  # Obstacle Callbacks

  def handle_info(:create_obstacle, state) do
    updated_state = Invermore.Game.Obstacle.create(state)
    send_updated_state_to_live_view(updated_state)

    {:noreply, valid_movement(updated_state)}
  end

  def handle_info({:move_obstacle, id}, state) do
    updated_state = Invermore.Game.Obstacle.move(id, state)
    send_updated_state_to_live_view(updated_state)

    {:noreply, valid_movement(updated_state)}
  end

  # Icon Callbacks

  def handle_info({:continue_icon_movement, direction}, state) do
    updated_state = Invermore.Game.Icon.continue_movement(direction, state)
    send_updated_state_to_live_view(updated_state)

    {:noreply, valid_movement(updated_state)}
  end

  def handle_call({:move_icon, direction}, _from, state) do
    updated_state =
      direction
      |> Invermore.Game.Icon.move(state)
      |> valid_movement()

    {:reply, updated_state, updated_state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:restart_game, _from, state) do
    default_state = %Invermore.Game.State{live_view_pid: state.live_view_pid, restarting_game: true, game_over: true, difficulty_level: state.difficulty_level}
    {:reply, default_state, default_state}
  end

  def handle_call(:complete_game_restart, _from, state) do
    updated_state = %{state | restarting_game: false, game_over: false}
    start_game(updated_state.difficulty_level)

    {:reply, updated_state, updated_state}
  end

  def handle_call({:update_difficulty_level, level}, _from, state) do
    updated_state = %{state | difficulty_level: level}

    {:reply, updated_state, updated_state}
  end

  defp send_updated_state_to_live_view(%{live_view_pid: live_view_pid} = state) do
    send(live_view_pid, %{action: "update_state", state: state})
  end

  defp valid_movement(state) do
    Invermore.Game.Validator.validate_movement(state)
  end

  defp start_game(difficulty_level) do
    Process.send_after(self(), :create_obstacle, Levels.create_obstacle_time(difficulty_level))
    Process.send_after(self(), :increase_score, Levels.increase_score_time(difficulty_level))
    Process.send_after(self(), :create_prize, 1000)
  end
end
