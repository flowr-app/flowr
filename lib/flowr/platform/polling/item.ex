defmodule Flowr.Platform.Polling.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "polling_items" do
    field :data, :map
    field :item_id, :string

    belongs_to(:polling, Flowr.Platform.Polling)

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:data, :item_id])
    |> validate_required([:data, :item_id])
    |> unique_constraint(:item_id, name: :polling_items_polling_id_item_id_index)
  end
end
