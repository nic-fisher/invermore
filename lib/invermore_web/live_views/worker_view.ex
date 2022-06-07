defmodule InvermoreWeb.WorkerLiveView do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(InvermoreWeb.WorkerView, "show.html", assigns)
  end

  def mount(_params, _, socket) do
    current_state = Invermore.Worker.get_state()
    {:ok, assign(socket, :current_state, current_state)}
  end

  def handle_event("update-state", _params, socket) do
    Invermore.Worker.push(:world)
    {:noreply, socket}
  end

  def handle_event("get-state", _params, socket) do
    current_state = Invermore.Worker.get_state()
    {:noreply, assign(socket, current_state: current_state)}
  end

  def handle_event("pop-from-state", _params, socket) do
    Invermore.Worker.pop()
    {:noreply, socket}
  end
end
