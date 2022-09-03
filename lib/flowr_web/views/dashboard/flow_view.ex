defmodule FlowrWeb.Dashboard.FlowView do
  use FlowrWeb, :view

  def connectors_options() do
    Flowr.Exterior.list_connectors()
    |> Enum.map(fn connector -> {connector.name, connector.id} end)
  end

  def connector_accounts_options(conn) do
    customer = Plug.Conn.get_session(conn, :current_customer)

    customer
    |> Flowr.Exterior.list_accounts()
    |> Enum.map(fn account -> {account.name, account.id} end)
  end

  def functions_for_select(form) do
    case Phoenix.HTML.Form.input_value(form, :connector_id) do
      nil ->
        []

      connector_id ->
        connector = Flowr.Exterior.get_connector!(connector_id)

        connector
        |> Flowr.Exterior.Connector.get_functions()
        |> Enum.map(fn function -> {function.name, function.name} end)
    end
  end

  def value_for_args_template(form) do
    args_template = Phoenix.HTML.Form.input_value(form, :args_template)
    connector_id = Phoenix.HTML.Form.input_value(form, :connector_id)
    function_id = Phoenix.HTML.Form.input_value(form, :function)

    case args_template do
      nil ->
        get_args_template_for_function(connector_id, function_id)

      args_template ->
        if Enum.empty?(args_template) do
          get_args_template_for_function(connector_id, function_id)
        else
          args_template
        end
    end
    |> Jason.encode!(pretty: true)
  end

  defp get_args_template_for_function(nil, _), do: %{}

  defp get_args_template_for_function(connector_id, function_id) do
    connector = Flowr.Exterior.get_connector!(connector_id)

    fun =
      connector
      |> Flowr.Exterior.Connector.get_functions()
      |> Enum.find(%{arg_template: %{}}, fn f ->
        function_id == f.name
      end)

    fun.arg_template
  end
end
