defmodule Flowr.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {Flowr.Repo, []},
      {Flowr.Automation.Workflow, []},
      {Flowr.Platform.Polling.Worker, []},
      {Flowr.Accounts.RefreshTokenBroadway, []},
      {RingCentral.HTTPClient.DefaultClient, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
