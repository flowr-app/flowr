defmodule Flowr.Exterior.Connector.Behaviour.Builtin do
  @type map_with_string_keys :: %{optional(binary()) => any}

  @callback config() :: map()
  @callback auth_info() :: map()
  @callback functions() :: [map()]
  @callback run(
              function :: binary,
              config :: map_with_string_keys,
              meta :: map_with_string_keys,
              credentials :: map_with_string_keys,
              args :: map_with_string_keys
            ) ::
              {:ok, map_with_string_keys} | {:error, map_with_string_keys}
end
