defmodule Flowr.Accounts.RefreshTokenBroadway do
  use Broadway

  require Logger

  alias Broadway.Message
  alias Flowr.Accounts.RefreshTokenBroadway.{Producer, Acknowledger}

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Producer, []},
        transformer: {__MODULE__, :transform, []},
        concurrency: 1
      ],
      processors: [
        refresh_token: [concurrency: 2]
      ]
    )
  end

  def transform(customer, _opts) do
    %Message{
      data: customer,
      acknowledger: Acknowledger.build_acknowledger(customer.id, customer)
    }
  end

  @impl true
  def handle_message(:refresh_token, %Broadway.Message{data: customer} = message, _context) do
    case Flowr.Accounts.refresh_token(customer) do
      {:ok, updated_customer} ->
        message
        |> Broadway.Message.update_data(fn _customer ->
          updated_customer
        end)

      {:error, err} ->
        Broadway.Message.failed(message, err)
    end
  end

  @impl true
  def handle_failed(messages, _context) do
    messages
    |> Enum.map(fn %Broadway.Message{data: customer, status: {:failed, err}} = message ->
      Logger.warn("Failed: #{customer.id}")
      Logger.warn("Failed: #{err.detail.status}")

      message
    end)
  end
end
