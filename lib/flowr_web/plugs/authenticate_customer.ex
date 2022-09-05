defmodule FlowrWeb.Plugs.AuthenticateCustomer do
  import Plug.Conn
  import Phoenix.Controller

  alias FlowrWeb.Router.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:current_customer] do
      conn
    else
      conn
      |> put_flash(:error, "You need to sign in or sign up before continuing.")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
