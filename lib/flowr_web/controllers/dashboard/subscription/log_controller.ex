defmodule FlowrWeb.Dashboard.Subscription.LogController do
  use FlowrWeb, :controller

  alias Flowr.Platform

  def index(conn, _params, subscription) do
    subscription_logs = Platform.list_subscription_logs(subscription)
    render(conn, "index.html", subscription_logs: subscription_logs)
  end

  def action(conn, _) do
    subscription = Platform.get_subscription!(conn.params["subscription_id"])

    args = [conn, conn.params, subscription]
    apply(__MODULE__, action_name(conn), args)
  end
end
