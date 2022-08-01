defmodule Invermore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Invermore.Repo,
      # Start the Telemetry supervisor
      InvermoreWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Invermore.PubSub},
      # Start the Endpoint (http/https)
      InvermoreWeb.Endpoint,
      # {Invermore.Game, []},
      {DynamicSupervisor, name: Invermore.Game.Supervisor, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Invermore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    InvermoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
