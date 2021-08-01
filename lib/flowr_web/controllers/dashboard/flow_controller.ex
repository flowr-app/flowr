defmodule FlowrWeb.Dashboard.FlowController do
  use FlowrWeb, :controller

  alias Flowr.Automation
  alias Flowr.Automation.Flow

  def index(conn, _params) do
    customer = get_session(conn, :current_customer)

    flows =
      Automation.list_flows(customer)
      |> Flowr.Repo.preload(:trigger)

    render(conn, "index.html", flows: flows)
  end

  def new(conn, _params) do
    flow = %Flow{}
    render(conn, "new.html", flow: flow)
  end

  def create(conn, %{"flow" => flow_params}) do
    customer = get_session(conn, :current_customer)

    case Automation.create_flow(customer, flow_params) do
      {:ok, _flow} ->
        conn
        |> put_flash(:info, "Flow created successfully.")
        |> redirect(to: Routes.dashboard_flow_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    flow =
      Automation.get_flow!(id)
      |> Flowr.Repo.preload(:trigger)

    render(conn, "show.html", flow: flow)
  end

  def edit(conn, %{"id" => id}) do
    flow = Automation.get_flow!(id)
    render(conn, "edit.html", flow: flow)
  end

  def update(conn, %{"id" => id, "flow" => flow_params}) do
    flow = Automation.get_flow!(id)

    case Automation.update_flow(flow, flow_params) do
      {:ok, _flow} ->
        conn
        |> put_flash(:info, "Flow updated successfully.")
        |> redirect(to: Routes.dashboard_flow_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", flow: flow, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    flow = Automation.get_flow!(id)
    {:ok, _flow} = Automation.delete_flow(flow)

    conn
    |> put_flash(:info, "Flow deleted successfully.")
    |> redirect(to: Routes.dashboard_flow_path(conn, :index))
  end

  def action(conn, _) do
    customer = get_session(conn, :current_customer)

    conn =
      conn
      |> assign(:current_customer, customer)

    args = [conn, conn.params]
    apply(__MODULE__, action_name(conn), args)
  end
end
