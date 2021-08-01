defmodule Flowr.Exterior.Connector.RunInfo do
  @moduledoc """
  %{
    adapter: "local",
    connection_info: %{
      "authorize": {
        method: 'GET'
        headers: [],
        body:
      }
    }
  }
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  embedded_schema do
    field :adapter, :string
    field :source_code, :string
    field :lambda_url, :map
  end

  @doc false
  def changeset(auth, attrs) do
    auth
    |> cast(attrs, [:adapter, :source_code, :lambda_url])
    |> validate_required([:adapter])
    |> validate_inclusion(:adapter, Flowr.Automation.Runner.Adapter.adapters())
  end
end
