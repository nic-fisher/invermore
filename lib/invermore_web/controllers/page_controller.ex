defmodule InvermoreWeb.PageController do
  use InvermoreWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
