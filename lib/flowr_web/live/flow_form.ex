defmodule FlowrWeb.Live.FlowForm do
  use Phoenix.LiveView

  alias Flowr.Automation
  alias Flowr.Automation.Flow
  alias Flowr.Automation.Action

  def render(assigns) do
    FlowrWeb.Dashboard.FlowView.render("form.html", assigns)
  end

  def mount(
        :not_mounted_at_router,
        %{"flow" => flow, "current_customer" => current_customer},
        socket
      ) do
    changeset = Automation.change_flow(flow)

    triggers_for_select =
      current_customer
      |> Flowr.Platform.list_triggers()
      |> Enum.map(fn trigger ->
        {
          "#{trigger.name} (#{trigger.category})",
          trigger.id
        }
      end)

    connector_accounts_for_select =
      current_customer
      |> Flowr.Exterior.list_accounts()
      |> Enum.map(fn account -> {account.name, account.id} end)

    connectors_for_select =
      Flowr.Exterior.list_connectors()
      |> Enum.map(fn connector -> {connector.name, connector.id} end)

    socket =
      socket
      |> assign(current_customer: current_customer)
      |> assign(changeset: changeset)
      |> assign(triggers_for_select: triggers_for_select)
      |> assign(connector_accounts_for_select: connector_accounts_for_select)
      |> assign(connectors_for_select: connectors_for_select)

    {:ok, socket}
  end

  def handle_event("add_action", _, socket) do
    socket = update(socket, :changeset, &add_action/1)

    {:noreply, socket}
  end

  def handle_event("validate", %{"flow" => flow_params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Automation.change_flow(flow_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"flow" => flow_params}, socket) do
    case save_flow(flow_params, socket) do
      {:ok, _flow} ->
        {:noreply,
         socket
         |> put_flash(:info, "flow created")
         |> redirect(to: FlowrWeb.Router.Helpers.dashboard_flow_path(FlowrWeb.Endpoint, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_flow(flow_params, socket) do
    case socket.assigns.changeset.data do
      %Flow{id: nil} ->
        Automation.create_flow(socket.assigns.current_customer, flow_params)

      %Flow{id: _} = flow ->
        Automation.update_flow(flow, flow_params)
    end
  end

  defp add_action(changeset) do
    new_action = Automation.change_action(%Action{})

    case Ecto.Changeset.get_field(changeset, :actions) do
      nil ->
        changeset
        |> Ecto.Changeset.put_embed(:actions, [new_action])

      actions ->
        changeset
        |> Ecto.Changeset.put_embed(:actions, actions ++ [new_action])
    end
  end
end
