defmodule Flowr.Automation.Runner.Run do
  @type t :: %__MODULE__{
          connector: Flowr.Exterior.Connector.t(),
          function: binary(),
          config: %{optional(binary()) => any},
          meta: Flowr.Exterior.Connector.Meta.run_t(),
          credentials: %{optional(binary()) => any}
        }

  defstruct [:connector, :function, :config, :meta, :credentials]
end
