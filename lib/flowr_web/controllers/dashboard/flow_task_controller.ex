defmodule FlowrWeb.Dashboard.FlowTaskController do
  use FlowrWeb, :controller

  alias Flowr.Automation

  def index_all(conn, _params) do
    current_customer = conn.assigns.current_customer
    flow_tasks = Automation.list_flow_tasks(current_customer)
    render(conn, "index_all.html", flow_tasks: flow_tasks)
  end

  def index(conn, params) do
    flow = Automation.get_flow!(params["flow_id"])

    flow_tasks = Automation.list_flow_tasks(flow)
    render(conn, "index.html", flow_tasks: flow_tasks)
  end

  def show(conn, %{"id" => id}) do
    task = Automation.get_task!(id)
    render(conn, "show.html", task: task)
  end
end
