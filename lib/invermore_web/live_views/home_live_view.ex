defmodule InvermoreWeb.HomeLiveView do
  use Phoenix.LiveView

  alias Invermore.Game

  def render(%{page: "error"} = assigns) do
    ~L"<div>Oops, something went wrong and we're unable to start the game.</div>"
  end

  def render(assigns) do
    Phoenix.View.render(InvermoreWeb.HomeView, "show.html", assigns)
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
end
