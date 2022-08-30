defmodule FlowrWeb.API.WebhookController do
  use FlowrWeb, :controller

  alias Flowr.Platform

  def create(conn, _params) do
    create_webhook_log(conn)

    conn
    |> resp(200, "")
  end

  defp create_webhook_log(conn) do
    callback_info = conn.body_params

    webhook = Platform.get_webhook_by_endpoint_id!(conn.path_params["id"])
    # TODO
    # Platform.create_webhook_log(webhook, %{info: callback_info})
  end
end
