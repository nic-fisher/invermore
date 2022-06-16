defmodule InvermoreWeb.GameLiveView do
  use Phoenix.LiveView

  alias Invermore.Game

  def render(assigns) do
    Phoenix.View.render(InvermoreWeb.GameView, "show.html", assigns)
  end

  def mount(_params, _, socket) do
    state = Game.get_state()
    {:ok, assign(socket, game_state: state)}
  end

  def handle_event("key_pressed", %{"key" => "ArrowRight"}, socket) do
    Game.move("right")
    state = Game.get_state()

    {:noreply, assign(socket, game_state: state)}
  end

  def handle_event("key_pressed", %{"key" => "ArrowLeft"}, socket) do
    Game.move("left")
    state = Game.get_state()

    {:noreply, assign(socket, game_state: state)}
  end

  def handle_event("key_pressed", %{"key" => "ArrowUp"}, socket) do
    Game.move("up")
    state = Game.get_state()

    {:noreply, assign(socket, game_state: state)}
  end

  def handle_event("key_pressed", %{"key" => "ArrowDown"}, socket) do
    Game.move("down")
    state = Game.get_state()

    {:noreply, assign(socket, game_state: state)}
  end

  def handle_event("key_pressed", %{"key" => _}, socket) do
    {:noreply, socket}
  end
end
