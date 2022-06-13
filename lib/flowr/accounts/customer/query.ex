defmodule Flowr.Accounts.Customer.Query do
  import Ecto.Query

  alias Flowr.Accounts.Customer

  def all do
    from(q in Customer)
  end

  def token_expires_soon(query \\ Customer) do
    # buffer for the token
    five_minutes_ago =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-5 * 60, :second)

    from q in query,
      where: q.access_token_expires_at < ^five_minutes_ago
  end

  def is_active(query \\ Customer) do
    from q in query,
      where: fragment("(? -> ?)::boolean is ?", q.status, "active?", true)
  end
end
