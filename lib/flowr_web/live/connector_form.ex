defmodule FlowrWeb.Live.ConnectorForm do
  use Phoenix.LiveView

  alias Flowr.Exterior
  alias Flowr.Exterior.Connector

  def render(assigns) do
    adapter_name = assigns.changeset.data.adapter_name

    FlowrWeb.Developer.ConnectorView.render("form_#{adapter_name}.html", assigns)
  end

  def mount(:not_mounted_at_router, %{"connector" => connector}, socket) do
    changeset = Exterior.change_connector(connector)

    socket =
      socket
      |> assign(changeset: changeset)

    {:ok, socket}
  end

  def handle_event("add_function", _, socket) do
    {:noreply, update(socket, :changeset, &add_function/1)}
  end

  def handle_event("save", %{"connector" => connector_params}, socket) do
    case save_connector(connector_params, socket) do
      {:ok, _connector} ->
        {:noreply,
         socket
         |> put_flash(:info, "connector created")
         |> redirect(
           to: FlowrWeb.Router.Helpers.developer_connector_path(FlowrWeb.Endpoint, :index)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_connector(connector_params, socket) do
    case socket.assigns.changeset.data do
      %Connector{id: nil} ->
        Exterior.create_connector(connector_params)

      %Connector{id: _} = connector ->
        Exterior.update_connector(connector, connector_params)
    end
  end

  defp add_function(changeset) do
    new_function = Exterior.change_function(%Flowr.Exterior.Connector.Function{})

    case Ecto.Changeset.get_field(changeset, :functions) do
      nil ->
        changeset
        |> Ecto.Changeset.put_embed(:functions, [new_function])

      functions ->
        changeset
        |> Ecto.Changeset.put_embed(:functions, functions ++ [new_function])
    end
  end
end
