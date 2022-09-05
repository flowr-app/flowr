defmodule FlowrWeb.Dashboard.PollingController do
  use FlowrWeb, :controller

  alias Flowr.Platform
  alias Flowr.Platform.Polling

  def index(conn, _params) do
    pollings = Platform.list_pollings(conn.assigns.current_customer)
    render(conn, "index.html", pollings: pollings)
  end

  def new(conn, _params) do
    changeset = Platform.change_polling(%Polling{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"polling" => polling_params}) do
    customer = conn.assigns.current_customer

    case Platform.create_polling(customer.id, polling_params) do
      {:ok, _polling} ->
        conn
        |> put_flash(:info, "Polling created successfully.")
        |> redirect(to: Routes.dashboard_polling_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    polling = Platform.get_polling!(id)
    {:ok, _polling} = Platform.delete_polling(polling)

    conn
    |> put_flash(:info, "Polling deleted successfully.")
    |> redirect(to: Routes.dashboard_polling_path(conn, :index))
  end
end
