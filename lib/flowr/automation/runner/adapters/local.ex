defmodule Flowr.Automation.Runner.Adapter.Local do
  @behaviour Flowr.Automation.Runner.Adapter

  require Logger

  alias Flowr.Automation.Runner.Run

  @impl true
  def run(%Run{connector: connector} = run, args) do
    Logger.info("[Local Runner] Running #{inspect(run)} with args: #{inspect(args)}")

    # `mod` will implement `Flowr.Exterior.Connector.Behaviour`
    [{mod, _}] = Code.compile_string(connector.run_info.source_code)

    mod.run(run.function, run.config, run.meta, run.credentials, args)
  end
end
