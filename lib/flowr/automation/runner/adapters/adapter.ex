defmodule Flowr.Automation.Runner.Adapter do
  alias Flowr.Automation.Runner.Run

  @type map_with_string_keys :: %{optional(binary()) => any}

  @callback run(run :: Run.t(), args :: map_with_string_keys) ::
              {:ok, map_with_string_keys} | {:error, map_with_string_keys}

  def adapters do
    ~w(local aws_lambda)
  end

  @spec adapter_for(binary()) ::
          Flowr.Automation.Runner.Adapter.AWSLambda | Flowr.Automation.Runner.Adapter.Local
  def adapter_for("local") do
    Flowr.Automation.Runner.Adapter.Local
  end

  def adapter_for("aws_lambda") do
    Flowr.Automation.Runner.Adapter.AWSLambda
  end

  def adapter_for(_) do
    # fallback to local adpater if non-existing
    adapter_for("local")
  end
end
