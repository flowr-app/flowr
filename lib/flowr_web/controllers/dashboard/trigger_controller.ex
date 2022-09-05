defmodule FlowrWeb.Dashboard.TriggerController do
  use FlowrWeb, :controller

  alias Flowr.Platform
  alias Flowr.Platform.Trigger

  def index(conn, _params) do
    triggers =
      Platform.list_triggers(conn.assigns.current_customer)
      |> Flowr.Repo.preload([:polling, :subscription, :webhook])

    render(conn, "index.html", triggers: triggers)
  end

  def new(conn, _params) do
    trigger = %Trigger{category: "subscription"}
    render(conn, "new.html", trigger: trigger)
  end

  def create(conn, %{"trigger" => trigger_params}) do
    customer = conn.assigns.current_customer

    case Platform.create_trigger(customer.id, trigger_params) do
      {:ok, _trigger} ->
        conn
        |> put_flash(:info, "Trigger created successfully.")
        |> redirect(to: Routes.dashboard_trigger_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    trigger = Platform.get_trigger!(id)
    {:ok, _trigger} = Platform.delete_trigger(trigger)

    conn
    |> put_flash(:info, "Trigger deleted successfully.")
    |> redirect(to: Routes.dashboard_trigger_path(conn, :index))
  end
end
