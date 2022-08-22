defmodule Invermore.Game do
  use GenServer, restart: :transient

  @directions [:left, :right, :up, :down]

  # Client API

  def start_link(live_view_pid) do
    GenServer.start_link(__MODULE__, live_view_pid)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def move_icon(pid, direction) when direction in @directions do
    GenServer.call(pid, {:move_icon, direction})
  end

  # Server Callbacks

  def init(live_view_pid) do
    {:ok, %Invermore.Game.State{live_view_pid: live_view_pid},
     {:continue, :start_game}}
  end

  def handle_continue(:start_game, state) do
    Process.send_after(self(), :create_obstacle, 3000)
    Process.send_after(self(), :increase_score, 1000)
    Process.send_after(self(), :create_prize, 1000)
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

  defp send_updated_state_to_live_view(%{live_view_pid: live_view_pid} = state) do
    send(live_view_pid, %{action: "update_state", state: state})
  end

  defp valid_movement(state) do
    Invermore.Game.Validator.validate_movement(state)
  end
end
