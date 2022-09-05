defmodule FlowrWeb.Plugs.SetCurrentCustomer do
  import Plug.Conn

  alias Flowr.Repo
  alias Flowr.Accounts.Customer

  def init(_params) do
  end

  def call(conn, _params) do
    current_customer_id = Plug.Conn.get_session(conn, :current_customer_id)

    cond do
      current_customer = current_customer_id && Repo.get(Customer, current_customer_id) ->
        conn
        |> assign(:current_customer, current_customer)

      true ->
        conn
        |> assign(:current_customer, nil)
    end
  end
end
