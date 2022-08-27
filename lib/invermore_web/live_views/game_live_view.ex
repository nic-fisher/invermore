defmodule InvermoreWeb.GameLiveView do
  use Phoenix.LiveView
  require Logger

  alias Invermore.Game

  def render(%{page: "error"} = assigns) do
    ~L"<div>Oops, something went wrong and we're unable to start the game.</div>"
  end

  def render(assigns) do
    Phoenix.View.render(InvermoreWeb.GameView, "show.html", assigns)
  end

  def mount(_params, _, socket) do
    {:ok, assign(socket, game_state: %Invermore.Game.State{})}
  end

  def handle_event(
        "key_pressed",
        %{"key" => " "},
        %{assigns: %{game_state: %{live_view_pid: nil}}} = socket
      ) do
    with true <- connected?(socket),
         {:ok, game_pid} = Game.Manager.start_game() do
      state = Game.get_state(game_pid)
      {:noreply, assign(socket, game_state: state, pid: game_pid)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event(
    "key_pressed",
    %{"key" => " "},
    %{assigns: %{game_state: %{game_over: true}}} = socket
  ) do
    state = Game.Manager.restart_game(socket.assigns.pid)
    {:noreply, assign(socket, game_state: state)}
  end

  def handle_event(
    "key_pressed",
    _,
    %{assigns: %{game_state: %{live_view_pid: nil}}} = socket
  ) do
    {:noreply, socket}
  end

  def handle_event("key_pressed", %{"key" => key_pressed}, socket)
    when key_pressed in ["ArrowRight", "ArrowLeft", "ArrowUp", "ArrowDown"] do
    updated_state = Game.Manager.move(socket.assigns.pid, key_pressed)

    {:noreply, assign(socket, game_state: updated_state)}
  end

  def handle_event("key_pressed", %{"key" => _key_pressed}, socket) do
    {:noreply, socket}
  end

  def handle_info(%{action: "update_state", state: state}, socket) do
    {:noreply, assign(socket, game_state: state)}
  end
end
