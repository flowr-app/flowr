defmodule FlowrWeb.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: FlowrWeb.PubSub},
      # Start the Endpoint (http/https)
      {FlowrWeb.Endpoint, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FlowrWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
