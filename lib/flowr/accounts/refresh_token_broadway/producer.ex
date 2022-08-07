defmodule Flowr.Accounts.RefreshTokenBroadway.Producer do
  @moduledoc """
  The GenStage Producer impl
  to fetch customers with a refresh token expires soon.
  """

  use GenStage

  require Logger

  alias Flowr.Accounts

  # The interval to polling for data
  # in ms
  @default_receive_interval 30_000

  @impl GenStage
  def init(opts) do
    receive_interval = opts[:receive_interval] || @default_receive_interval

    {:producer,
     %{
       demand: 0,
       receive_timer: nil,
       receive_interval: receive_interval
     }}
  end

  @impl GenStage
  def handle_demand(incoming_demand, %{demand: demand} = state) do
    handle_receive_messages(%{state | demand: demand + incoming_demand})
  end

  @impl GenStage
  def handle_info(:fetch_more, state) do
    handle_receive_messages(%{state | receive_timer: nil})
  end

  def handle_info({:fetch_one, customer_id}, state) do
    Logger.debug("Fetching one customer: #{customer_id}")

    customer = Accounts.get_customer!(customer_id)
    {:noreply, [customer], state}
  end

  def handle_info(_, state) do
    {:noreply, [], state}
  end

  def add_customer(customer_id) do
    Process.send(self(), {:fetch_one, customer_id}, [])
  end

  defp handle_receive_messages(%{receive_timer: nil, demand: demand} = state)
       when demand > 0 do
    customers =
      Accounts.Customer.Query.is_active()
      |> Accounts.Customer.Query.token_expires_soon()
      |> Accounts.list_customers(limit: demand)

    new_demand = demand - length(customers)

    receive_timer =
      case {customers, new_demand} do
        {[], _} -> schedule_fetch_more(state.receive_interval)
        {_, 0} -> nil
        _ -> schedule_fetch_more(state.receive_interval)
      end

    new_state = %{state | demand: new_demand, receive_timer: receive_timer}

    Logger.debug("Fetch customers (#{length(customers)}): #{Enum.map(customers, & &1.id)}")
    Logger.debug("New state: #{inspect(new_state)}")

    {:noreply, customers, new_state}
  end

  defp handle_receive_messages(state) do
    {:noreply, [], state}
  end

  defp schedule_fetch_more(interval) do
    Process.send_after(self(), :fetch_more, interval)
  end
end
