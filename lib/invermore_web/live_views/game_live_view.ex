defmodule InvermoreWeb.GameLiveView do
  use Phoenix.LiveView

  alias Invermore.Game

  def render(%{page: "error"} = assigns) do
    ~L"<div>Oops, something went wrong and we're unable to start the game.</div>"
  end

  def render(assigns) do
    Phoenix.View.render(InvermoreWeb.GameView, "show.html", assigns)
  end

  def mount(_params, _, socket) do
    with true <- connected?(socket),
         {:ok, game_pid} <- Game.Manager.start_game() do
      state = Game.get_state(game_pid)
      {:ok, assign(socket, game_state: state, pid: game_pid)}
    else
      false -> {:ok, assign(socket, game_state: %Invermore.Game.State{})}
      {:error, _} -> {:ok, assign(socket, page: "error")}
    end
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
