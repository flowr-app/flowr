defmodule FlowrWeb.Developer.ConnectorController do
  use FlowrWeb, :controller

  alias Flowr.Exterior
  alias Flowr.Exterior.Connector

  def index(conn, _params) do
    connectors = Exterior.list_connectors()
    render(conn, "index.html", connectors: connectors)
  end

  def new(conn, %{"adapter" => adapter}) do
    default_connector_params =
      case adapter do
        "dynamic" ->
          Exterior.Connector.Dynamic.default_connector_params()

        "builtin" ->
          Exterior.Connector.Builtin.default_connector_params()

        _ ->
          Exterior.Connector.Builtin.default_connector_params()
      end

    connector = struct(%Connector{}, default_connector_params)

    render(conn, "new.html", connector: connector)
  end

  def new(conn, _) do
    conn
    |> redirect(to: Routes.developer_connector_path(conn, :new, adapter: "local"))
  end

  def create(conn, %{"connector" => connector_params}) do
    case Exterior.create_connector(connector_params) do
      {:ok, connector} ->
        conn
        |> put_flash(:info, "Connector created successfully.")
        |> redirect(to: Routes.developer_connector_path(conn, :show, connector))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    connector = Exterior.get_connector!(id)
    render(conn, "show.html", connector: connector)
  end

  def edit(conn, %{"id" => id}) do
    connector = Exterior.get_connector!(id)
    render(conn, "edit.html", connector: connector)
  end

  def update(conn, %{"id" => id, "connector" => connector_params}) do
    connector = Exterior.get_connector!(id)

    case Exterior.update_connector(connector, connector_params) do
      {:ok, connector} ->
        conn
        |> put_flash(:info, "Connector updated successfully.")
        |> redirect(to: Routes.developer_connector_path(conn, :show, connector))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", connector: connector, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    connector = Exterior.get_connector!(id)
    {:ok, _connector} = Exterior.delete_connector(connector)

    conn
    |> put_flash(:info, "Connector deleted successfully.")
    |> redirect(to: Routes.developer_connector_path(conn, :index))
  end
end
