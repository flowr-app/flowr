defmodule Flowr.Exterior.Connector.Behaviour do
  alias Flowr.Exterior.Connector.Behaviour.Builtin
  alias Flowr.Exterior.Connector.Behaviour.Dynamic

  defmacro __using__(:builtin) do
    quote do
      @behaviour Builtin
    end
  end

  defmacro __using__(:dynamic) do
    quote do
      @behaviour Dynamic
    end
  end
end
