defmodule FlowrWeb.Live.TriggerForm do
  use Phoenix.LiveView

  alias Flowr.Platform

  def render(assigns) do
    FlowrWeb.Dashboard.TriggerView.render("form.html", assigns)
  end

  def mount(
        :not_mounted_at_router,
        %{"trigger" => trigger, "current_customer" => current_customer},
        socket
      ) do
    changeset = Platform.change_trigger(trigger, %{})

    socket =
      socket
      |> assign(current_customer: current_customer)
      |> assign(changeset: changeset)

    {:ok, socket}
  end

  def handle_event("validate", %{"trigger" => trigger_params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Platform.change_trigger(trigger_params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"trigger" => trigger_params}, socket) do
    IO.inspect(trigger_params)

    case Platform.create_trigger(socket.assigns.current_customer.id, trigger_params) do
      {:ok, _trigger} ->
        {:noreply,
         socket
         |> put_flash(:info, "trigger created")
         |> redirect(
           to: FlowrWeb.Router.Helpers.dashboard_trigger_path(FlowrWeb.Endpoint, :index)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
