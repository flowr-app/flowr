defmodule FlowrWeb.LayoutView do
  use FlowrWeb, :view

  @spec current_customer(Plug.Conn.t()) :: Flowr.Accounts.Customer.t()
  def current_customer(conn) do
    conn.assigns[:current_customer]
  end
end
