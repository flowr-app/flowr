defmodule Flowr.Platform do
  @moduledoc """
  The Platform context.
  """

  import Ecto
  import Ecto.Query, warn: false
  alias Flowr.Repo

  alias Flowr.Platform.{Subscription, Polling, Webhook, Trigger}

  @doc """
  Returns the list of subscriptions.

  ## Examples

      iex> list_subscriptions()
      [%Subscription{}, ...]

  """
  def list_subscriptions(customer) do
    customer
    |> Ecto.assoc(:subscriptions)
    |> Repo.all()
  end

  @doc """
  Gets a single subscription.

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

      iex> get_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription!(id), do: Repo.get!(Subscription, id)

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription(_customer_id, attrs \\ %{}) do
    changeset =
      %Subscription{}
      |> Subscription.creation_changeset(attrs)

    with {:ok, subscription} <- Repo.insert(changeset, read_after_writes: true),
         {:ok, subscription} <- create_remote_subscription(subscription) do
      {:ok, subscription}
    end
  end

  @doc """
  Updates a subscription.

  ## Examples

      iex> update_subscription(subscription, %{field: new_value})
      {:ok, %Subscription{}}

      iex> update_subscription(subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription(%Subscription{} = subscription, attrs) do
    subscription
    |> Subscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Subscription.

  ## Examples

      iex> delete_subscription(subscription)
      {:ok, %Subscription{}}

      iex> delete_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription changes.

  ## Examples

      iex> change_subscription(subscription)
      %Ecto.Changeset{source: %Subscription{}}

  """
  def change_subscription(%Subscription{} = subscription) do
    Subscription.changeset(subscription, %{})
  end

  def create_remote_subscription(%Subscription{} = subscription) do
    customer = Flowr.Accounts.get_customer!(subscription.trigger.customer_id)

    client = Flowr.Platform.Client.rest_client(customer.access_token)

    request_body = %{
      "eventFilters" => [
        subscription.event_type
      ],
      "deliveryMode" => %{
        "transportType" => "WebHook",
        "address" =>
          FlowrWeb.Router.Helpers.api_subscription_url(
            FlowrWeb.Endpoint,
            :create,
            subscription.id
          )
      }
    }

    with {:ok, %RingCentral.Response{data: data}} <-
           RingCentral.API.post(client, "subscription", Jason.encode!(request_body)),
         {:ok, subscription} <- update_subscription(subscription, %{subscription_info: data}) do
      {:ok, subscription}
    end
  end

  alias Flowr.Platform.Subscription.Log, as: SubscriptionLog

  @doc """
  Returns the list of subscription_logs.

  ## Examples

      iex> list_subscription_logs()
      [%SubscriptionLog{}, ...]

  """
  def list_subscription_logs(subscription) do
    query =
      from t in assoc(subscription, :logs),
        order_by: [desc: :inserted_at]

    Repo.all(query)
  end

  @doc """
  Gets a single subscription_log.

  Raises `Ecto.NoResultsError` if the Subscription log does not exist.

  ## Examples

      iex> get_subscription_log!(123)
      %SubscriptionLog{}

      iex> get_subscription_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription_log!(id), do: Repo.get!(SubscriptionLog, id)

  @doc """
  Creates a subscription_log.

  ## Examples

      iex> create_subscription_log(%{field: value})
      {:ok, %SubscriptionLog{}}

      iex> create_subscription_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription_log(subscription, attrs \\ %{}) do
    changeset =
      subscription
      |> build_assoc(:logs)
      |> SubscriptionLog.changeset(attrs)

    with {:ok, subscription_log} <- Repo.insert(changeset, read_after_writes: true),
         :ok <- Flowr.Automation.Trigger.create_tasks(subscription_log) do
      {:ok, subscription_log}
    end
  end

  def list_pollings() do
    query =
      from q in Polling,
        order_by: [desc: :inserted_at]

    Repo.all(query)
  end

  def list_pollings(customer) do
    customer
    |> Ecto.assoc(:pollings)
    |> Repo.all()
  end

  def get_polling!(id), do: Repo.get!(Polling, id)

  def create_polling(customer_id, attrs \\ %{}) do
    changeset =
      customer_id
      |> Polling.creation_changeset(%Polling{}, attrs)

    with {:ok, polling} <- Repo.insert(changeset, read_after_writes: true) do
      {:ok, polling}
    end
  end

  def delete_polling(%Polling{} = polling) do
    Repo.delete(polling)
  end

  def change_polling(%Polling{} = polling) do
    Polling.changeset(polling, %{})
  end

  def list_triggers(customer) do
    customer
    |> Ecto.assoc(:triggers)
    |> Repo.all()
  end

  def get_trigger!(id), do: Repo.get!(Trigger, id)

  def create_trigger(customer_id, attrs \\ %{}) do
    changeset =
      %Trigger{}
      |> Trigger.changeset(attrs)
      |> Ecto.Changeset.put_change(:customer_id, customer_id)

    with {:ok, trigger} <- Repo.insert(changeset, read_after_writes: true) do
      {:ok, trigger}
    end
  end

  def delete_trigger(%Trigger{} = trigger) do
    Repo.delete(trigger)
  end

  def change_trigger(%Trigger{} = trigger, params \\ %{}) do
    Trigger.changeset(trigger, params)
  end

  def list_polling_items(polling) do
    query =
      from t in assoc(polling, :items),
        order_by: [desc: :inserted_at]

    Repo.all(query)
  end

  def create_polling_item(polling, attrs) do
    item =
      polling
      |> build_assoc(:items)

    changeset = Polling.Item.changeset(item, attrs)

    Repo.insert(changeset,
      on_conflict: :nothing,
      conflict_target: [:polling_id, :item_id],
      returning: true
    )
  end

  # Create webhook
  def create_webhook(_customer_id, attrs \\ %{}) do
    changeset =
      %Webhook{}
      |> Webhook.creation_changeset(attrs)

    with {:ok, webhook} <- Repo.insert(changeset, read_after_writes: true) do
      {:ok, webhook}
    end
  end

  def get_webhook_by_endpoint_id!(endpoint_id) do
    query =
      from w in Webhook,
        where: w.endpoint_id == ^endpoint_id

    Repo.one!(query)
  end
end
