defmodule Flowr.Automation.Runner.Adapter.AWSLambda do
  @behaviour Flowr.Automation.Runner.Adapter

  require Logger

  alias Flowr.Automation.Runner.Run

  @impl true
  def run(%Run{} = run, args) do
    # TODO: implement this
    Logger.info("[AWSLambda Runner] Running #{inspect(run)} with args: #{inspect(args)}")

    {:ok, %{"x" => "y"}}
  end
end
