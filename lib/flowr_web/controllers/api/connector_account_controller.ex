defmodule FlowrWeb.API.ConnectorAccountController do
  use FlowrWeb, :controller

  alias Flowr.Exterior
  alias Flowr.Exterior.HTTPClient

  def callback(conn, %{"state" => connector_account_id, "code" => code}) do
    account = Exterior.get_account!(connector_account_id)

    with {:ok, json} <- HTTPClient.OAuth2.get_token(account, code),
         {:ok, _account} <- Exterior.update_account(account, %{credentials: json}) do
      conn
      |> redirect(to: Routes.dashboard_connector_account_path(conn, :index))
    end
  end
end
