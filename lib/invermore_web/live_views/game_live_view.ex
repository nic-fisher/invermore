defmodule InvermoreWeb.GameLiveView do
  use Phoenix.LiveView
  require Logger

  alias Invermore.Game

  def render(assigns) do
    # v = DynamicSupervisor.start_child(Invermore.Game.Supervisor, Invermore.Game)
    # Logger.info("New process: #{inspect(v)}")
    Logger.info("Render is called")

    Phoenix.View.render(InvermoreWeb.GameView, "show.html", assigns)
  end

  def mount(_params, _, socket) do
    # pid = start_game_process(socket)

    # things to do:
    # - remove process name
    # - update functions to call specific process id
    # - start process if the liveview process is connected
    # - store the pid in the game state
    Logger.info("Process #{inspect(self())}")

    if connected?(socket) do
      {:ok, pid} = DynamicSupervisor.start_child(Invermore.Game.Supervisor, {Invermore.Game, [restart: :transient]})
      poll_game_process(pid)
      state = Game.get_state(pid)
      {:ok, assign(socket, game_state: state, pid: pid)}
    else
      {:ok, assign(socket, game_state: %Invermore.Game.State{})}
    end
    # DynamicSupervisor.start_child(Invermore.Game.Supervisor, Invermore.Game)
    # state = Game.get_state()

    # Logger.info("Connected? #{connected?(socket)}")
    # Logger.info("Mount is called")

    # {:ok, assign(socket, game_state: state)}
  end

  def handle_event("key_pressed", %{"key" => key_pressed}, socket) when key_pressed in ["ArrowRight", "ArrowLeft", "ArrowUp", "ArrowDown"] do
    Logger.info("Socket #{inspect(socket)}")

    updated_state = Game.Manager.move(socket.assigns.pid, key_pressed)

    {:noreply, assign(socket, game_state: updated_state)}
  end

  def handle_event("key_pressed", %{"key" => _key_pressed}, socket) do
    {:noreply, socket}
  end

  def handle_info(%{action: "continue_movement", direction: direction}, socket) do
    updated_state = Game.Manager.continue_movement(socket.assigns.pid, direction)

    {:noreply, assign(socket, game_state: updated_state)}
  end

  def handle_info(%{action: "poll_game_process", game_pid: game_pid}, socket) do
    poll_game_process(game_pid)

    {:noreply, socket}
  end

  def poll_game_process(game_pid) do
    # continually poll the game process so we know it's still being used. Send every 5 seconds
    Game.Manager.poll_process(game_pid)
    Process.send_after(self(), %{action: "poll_game_process", game_pid: game_pid}, 5000)
  end
end
