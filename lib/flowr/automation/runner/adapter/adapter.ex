defmodule Flowr.Automation.Runner.Adapter do
  alias Flowr.Automation.Runner.Run

  @type map_with_string_keys :: %{optional(binary()) => any}

  @callback run(run :: Run.t(), args :: map_with_string_keys) ::
              {:ok, map_with_string_keys} | {:error, map_with_string_keys}

  def adapters do
    ~w(builtin dynamic aws_lambda)
  end

  def default_adapter do
    "builtin"
  end

  @spec adapter_for(binary()) ::
          Flowr.Automation.Runner.Adapter.AWSLambda
          | Flowr.Automation.Runner.Adapter.Builtin
          | Flowr.Automation.Runner.Adapter.Dynamic
  def adapter_for("builtin") do
    Flowr.Automation.Runner.Adapter.Builtin
  end

  def adapter_for("dynamic") do
    Flowr.Automation.Runner.Adapter.Dynamic
  end

  def adapter_for("aws_lambda") do
    Flowr.Automation.Runner.Adapter.AWSLambda
  end

  def adapter_for(other) do
    # raise if adapter non-existing
    raise "Unrecognized adapter: #{other}"
  end
end
