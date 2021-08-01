defmodule FlowrWeb.Dashboard.SubscriptionController do
  use FlowrWeb, :controller

  alias Flowr.Platform
  alias Flowr.Platform.Subscription

  def index(conn, _params) do
    subscriptions = Platform.list_subscriptions(current_customer(conn))
    render(conn, "index.html", subscriptions: subscriptions)
  end

  def new(conn, _params) do
    changeset = Platform.change_subscription(%Subscription{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"subscription" => subscription_params}) do
    customer = current_customer(conn)

    case Platform.create_subscription(customer.id, subscription_params) do
      {:ok, _subscription} ->
        conn
        |> put_flash(:info, "Subscription created successfully.")
        |> redirect(to: Routes.dashboard_subscription_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    subscription = Platform.get_subscription!(id)
    render(conn, "show.html", subscription: subscription)
  end

  def edit(conn, %{"id" => id}) do
    subscription = Platform.get_subscription!(id)
    changeset = Platform.change_subscription(subscription)
    render(conn, "edit.html", subscription: subscription, changeset: changeset)
  end

  def update(conn, %{"id" => id, "subscription" => subscription_params}) do
    subscription = Platform.get_subscription!(id)

    case Platform.update_subscription(subscription, subscription_params) do
      {:ok, subscription} ->
        conn
        |> put_flash(:info, "Subscription updated successfully.")
        |> redirect(to: Routes.dashboard_subscription_path(conn, :show, subscription))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", subscription: subscription, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    subscription = Platform.get_subscription!(id)
    {:ok, _subscription} = Platform.delete_subscription(subscription)

    conn
    |> put_flash(:info, "Subscription deleted successfully.")
    |> redirect(to: Routes.dashboard_subscription_path(conn, :index))
  end

  defp current_customer(conn) do
    get_session(conn, :current_customer)
  end
end
