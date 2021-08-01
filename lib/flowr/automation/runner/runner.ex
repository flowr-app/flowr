defmodule Flowr.Automation.Runner do
  require Logger

  alias Flowr.Automation.Action
  alias Flowr.Automation.Runner.Run

  def run_action(%Action{} = action, args) do
    account = Flowr.Exterior.get_account!(action.account_id)
    connector = Flowr.Exterior.get_connector!(action.connector_id)

    run = %Run{
      connector: connector,
      function: action.function,
      config: connector.config,
      meta: %{},
      credentials: account.credentials
    }

    Logger.info(
      "Running: #{connector.id}, account: #{account.id}, function: #{action.function}, args: #{
        inspect(args)
      }"
    )

    adapter = Flowr.Automation.Runner.Adapter.adapter_for(connector.run_info.adapter)

    adapter.run(run, args)
  end
end
