defmodule FlowrWeb.Dashboard.AccountController do
  use FlowrWeb, :controller

  alias Flowr.Exterior
  alias Flowr.Exterior.Account

  def index(conn, _params) do
    customer = get_session(conn, :current_customer)

    connector_accounts =
      Exterior.list_accounts(customer)
      |> Flowr.Repo.preload(:connector)

    render(conn, "index.html", connector_accounts: connector_accounts)
  end

  def new(conn, _params) do
    changeset = Exterior.change_account(%Account{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"account" => account_params}) do
    customer = get_session(conn, :current_customer)

    case Exterior.create_account(customer, account_params) do
      {:ok, _account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: Routes.dashboard_connector_account_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Exterior.get_account!(id)
    {:ok, _account} = Exterior.delete_account(account)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: Routes.dashboard_connector_account_path(conn, :index))
  end

  def auth(conn, %{"id" => id}) do
    account = Exterior.get_account!(id)

    auth_url = Flowr.Exterior.get_auth_url(account)

    conn
    |> redirect(external: auth_url)
  end
end
