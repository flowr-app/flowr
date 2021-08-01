defmodule FlowrWeb.Dashboard.ConnectorController do
  use FlowrWeb, :controller

  alias Flowr.Exterior

  def index(conn, _params) do
    connectors = Exterior.list_connectors()
    render(conn, "index.html", connectors: connectors)
  end
end
