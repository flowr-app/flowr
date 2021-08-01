defmodule Flowr.Accounts.Worker.RefreshTokenWorker do
  use GenServer

  alias Flowr.Accounts

  @shcedule_interval 30 * 1_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def work do
    Accounts.list_customers(:token_expires_soon)
    |> Enum.each(&refresh_token/1)
  end

  def refresh_token(customer) do
    {:ok, _customer} = Accounts.refresh_token(customer)
  end

  def handle_info(:work, state) do
    work()

    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, @shcedule_interval)
  end
end
