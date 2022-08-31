defmodule FlowrWeb.API.WebhookController do
  use FlowrWeb, :controller

  alias Flowr.Platform

  def create(conn, params) do
    webhook = Platform.get_webhook_by_endpoint_id!(conn.path_params["id"])

    Platform.create_webhook_log(webhook, %{payload: params})

    conn
    |> resp(200, "")
  end
end
