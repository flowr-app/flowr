defmodule Flowr.Exterior.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "connector_accounts" do
    field :credentials, :map, default: %{}
    field :name, :string

    belongs_to(:connector, Flowr.Exterior.Connector)
    belongs_to(:customer, Flowr.Accounts.Customer)

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(filter(attrs), [:name, :credentials, :connector_id])
    |> validate_required([:name, :credentials, :connector_id])
  end

  @doc false
  def creation_changeset(account, attrs) do
    account
    |> cast(filter(attrs), [:name, :connector_id])
    |> validate_required([:name, :connector_id])
  end

  defp filter(%{"credentials" => credentials} = params) when is_binary(credentials) do
    Map.put(params, "credentials", Jason.decode!(credentials))
  end

  defp filter(params), do: params
end
