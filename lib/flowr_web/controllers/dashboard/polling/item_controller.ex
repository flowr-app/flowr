defmodule FlowrWeb.Dashboard.Polling.ItemController do
  use FlowrWeb, :controller

  alias Flowr.Platform

  def index(conn, _params, polling) do
    items = Platform.list_polling_items(polling)

    render(conn, "index.html", items: items)
  end

  def action(conn, _) do
    polling = Platform.get_polling!(conn.params["polling_id"])

    args = [conn, conn.params, polling]
    apply(__MODULE__, action_name(conn), args)
  end
end
