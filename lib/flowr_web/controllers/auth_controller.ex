defmodule FlowrWeb.AuthController do
  use FlowrWeb, :controller

  alias Flowr.Platform.OAuth

  def new(conn, _params) do
    authorize_url = OAuth.authorize_url()

    conn
    |> redirect(external: authorize_url)
  end

  def callback(conn, params) do
    with %{"code" => code} <- params,
         {:ok, token} <- OAuth.get_token(code),
         {:ok, customer} <- Flowr.Accounts.create_customer_from_oauth_token(token) do
      conn
      |> put_session(:current_customer, customer)
      |> redirect(to: Routes.dashboard_dashboard_path(conn, :index))
    end
  end

  @spec delete(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def delete(conn, _params) do
    conn
    |> delete_session(:current_customer)
    |> put_flash(:info, "Sign out successfully.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
