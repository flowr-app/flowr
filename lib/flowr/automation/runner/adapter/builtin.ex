defmodule Flowr.Automation.Runner.Adapter.Builtin do
  @behaviour Flowr.Automation.Runner.Adapter

  require Logger

  alias Flowr.Automation.Runner.Run

  @impl true
  def run(%Run{connector: connector} = run, args) do
    Logger.info("[Runner - Builtin] Running #{inspect(run)} with args: #{inspect(args)}")

    mod =
      Flowr.Exterior.Connector.Builtin.get_connector_module(
        connector.run_info.builtin_connector_id
      )

    mod.run(
      run.function,
      run.config,
      run.meta,
      run.credentials,
      args
    )
  end
end
