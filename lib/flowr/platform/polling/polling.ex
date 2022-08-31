defmodule Flowr.Platform.Polling do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "pollings" do
    field :endpoint, :string

    belongs_to(:trigger, Flowr.Platform.Trigger)
    has_many(:items, Flowr.Platform.Polling.Item)

    timestamps()
  end

  @doc false
  def changeset(polling, attrs) do
    polling
    |> cast(attrs, [:endpoint])
    |> validate_required([:endpoint])
  end

  def creation_changeset(customer_id, polling, attrs) do
    polling
    |> cast(attrs, [:endpoint])
    |> put_change(:customer_id, customer_id)
    |> validate_required([:endpoint])
  end
end
