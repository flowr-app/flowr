defmodule FlowrWeb.Developer.ConnectorController do
  use FlowrWeb, :controller

  alias Flowr.Exterior
  alias Flowr.Exterior.Connector

  def index(conn, _params) do
    connectors = Exterior.list_connectors()
    render(conn, "index.html", connectors: connectors)
  end

  def new(conn, _params) do
    connector = %Connector{
      auth: %Flowr.Exterior.Connector.AuthInfo{
        auth_type: "oauth2",
        connection_info: %{
          "authorize" => %{
            "url" => "https://www.dropbox.com/oauth2/authorize",
            "params" => %{
              "client_id" => "<%= config[\"app_key\"] %>",
              "redirect_uri" => "<%= meta.redirect_uri %>",
              "response_type" => "code",
              "state" => "<%= meta.state %>"
            }
          },
          "get_token" => %{
            "url" => "https://api.dropboxapi.com/oauth2/token",
            "method" => "POST",
            "body" => %{
              "code" => "<%= input.code %>",
              "grant_type" => "authorization_code",
              "client_id" => "<%= config[\"app_key\"] %>",
              "client_secret" => "<%= config[\"app_secret\"] %>",
              "redirect_uri" => "<%= meta.redirect_uri %>"
            },
            "headers" => %{
              "content-type" => "application/x-www-form-urlencoded"
            }
          }
        }
      }
    }

    render(conn, "new.html", connector: connector)
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
