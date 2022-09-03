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

  @primary_key false

  embedded_schema do
    # dynamic
    field :source_code, :string
    # aws_lambda
    field :lambda_url, :map
    # builtin
    field :builtin_connector_id, :string
  end

  @doc false
  def changeset(auth, attrs) do
    auth
    |> cast(attrs, [:source_code, :lambda_url, :builtin_connector_id])
  end
end
