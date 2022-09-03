defmodule Flowr.Exterior.Connector.Builtin do
  alias Flowr.Exterior.Connector.Builtin.Dropbox

  def get_connector_module("dropbox") do
    Dropbox
  end

  def builtin_connectors do
    [Dropbox.id()]
  end

  def get_auth_info(connector) do
    connector
    |> get_module()
    |> apply(:auth_info, [])
  end

  def get_functions(connector) do
    connector
    |> get_module()
    |> apply(:functions, [])
  end

  def default_connector_params do
    %{
      adapter_name: "builtin"
    }
  end

  defp get_module(connector) do
    get_connector_module(connector.run_info.builtin_connector_id)
  end
end
