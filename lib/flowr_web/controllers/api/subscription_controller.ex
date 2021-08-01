defmodule FlowrWeb.API.SubscriptionController do
  use FlowrWeb, :controller

  alias Flowr.Platform

  def create(conn, _params) do
    case get_validation_token(conn) do
      nil ->
        create_subscription_log(conn)

        conn
        |> resp(200, "")

      validate_token ->
        # handle initial check while creating the webhook
        conn
        |> put_resp_header("validation-token", validate_token)
        |> resp(200, "")
    end
  end

  def get_validation_token(conn) do
    case get_req_header(conn, "validation-token") do
      [] -> nil
      [validate_token | _] -> validate_token
    end
  end

  defp create_subscription_log(conn) do
    callback_info = conn.body_params

    subscription = Platform.get_subscription!(conn.path_params["id"])
    Platform.create_subscription_log(subscription, %{info: callback_info})
  end
end
