defmodule Flowr.Repo do
  use Ecto.Repo,
    otp_app: :flowr,
    adapter: Ecto.Adapters.Postgres
end
