defmodule Flowr.Platform.Polling.Worker do
  use GenServer

  alias Flowr.Platform
  require Logger

  @schedule_interval 60 * 1_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def work do
    Platform.list_pollings()
    |> Flowr.Repo.preload(trigger: :customer)
    |> Enum.map(&fetch_data/1)
    |> Enum.map(&create_items/1)
  end

  def fetch_data(polling) do
    Logger.debug("Start fetch data for polling: #{polling.id}")

    client = Flowr.Platform.Client.rest_client(polling.trigger.customer.access_token)

    with {:ok, %RingCentral.Response{status: 200, data: data}} <-
           RingCentral.API.get(client, polling.endpoint) do
      {polling, data["records"]}
    else
      {:ok, %RingCentral.Response{status: 401, data: %{"errorCode" => "TokenInvalid"}}} ->
        Logger.warn("Customer access token is invalid.")
        # Access token invalid, try refresh token
        Flowr.Accounts.RefreshTokenBroadway.Producer.add_customer(polling.trigger.customer_id)

        {polling, []}

      {:ok, %RingCentral.Response{status: status, data: data}} when status >= 500 ->
        Logger.warn(
          "Server 5xx, failed to fetch data from API server, status: #{status}, data: #{Jason.encode!(data)}"
        )

        {polling, []}

      {:error, err} ->
        Logger.warn(
          "Failed to fetch data from API server, error: #{inspect(err)} will try next attempt."
        )

        {polling, []}
    end
  end

  def create_items({polling, records}) do
    records
    |> Enum.map(&create_item(polling, &1))
  end

  def create_item(polling, record) do
    with {:ok, item} <-
           Platform.create_polling_item(polling, %{
             item_id: record["id"] |> to_string(),
             data: record
           }),
         :ok <- Flowr.Automation.Trigger.create_tasks(item) do
      :ok
    end
  end

  def handle_info(:work, state) do
    work()

    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, @schedule_interval)
  end
end
