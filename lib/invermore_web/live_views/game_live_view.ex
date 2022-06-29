defmodule InvermoreWeb.GameLiveView do
  use Phoenix.LiveView

  alias Invermore.{Game, GameManager}

  def render(assigns) do
    Phoenix.View.render(InvermoreWeb.GameView, "show.html", assigns)
  end

  def mount(_params, _, socket) do
    state = Game.get_state()
    {:ok, assign(socket, game_state: state)}
  end

  def handle_event("key_pressed", %{"key" => key_pressed}, socket) when key_pressed in ["ArrowRight", "ArrowLeft", "ArrowUp", "ArrowDown"] do
    updated_state = GameManager.move(key_pressed)

    {:noreply, assign(socket, game_state: updated_state)}
  end

  def handle_event("key_pressed", %{"key" => key_pressed}, socket) do
    {:noreply, socket}
  end

  def handle_info(%{action: "continue_movement", direction: direction}, socket) do
    updated_state = GameManager.continue_movement(direction)

    {:noreply, assign(socket, game_state: updated_state)}
  end
end
