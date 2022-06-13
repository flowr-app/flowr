defmodule Flowr.Accounts.RefreshTokenBroadway.Acknowledger do
  require Logger

  @behaviour Broadway.Acknowledger

  def build_acknowledger(ack_ref, customer) do
    {__MODULE__, ack_ref, customer}
  end

  @impl true
  def ack(_ack_ref, _successful, _failed) do
    # no ACK needed
  end
end
