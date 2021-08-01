defmodule Flowr.Automation.Flow do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "flows" do
    field :name, :string

    belongs_to(:trigger, Flowr.Platform.Trigger)
    belongs_to(:customer, Flowr.Accounts.Customer)
    has_many(:tasks, Flowr.Automation.Task)
    embeds_many(:actions, Flowr.Automation.Action)

    timestamps()
  end

  @doc false
  def changeset(flow, attrs) do
    flow
    |> cast(attrs, [:name, :trigger_id])
    |> validate_required([:name, :trigger_id])
    |> cast_embed(:actions, with: &Flowr.Automation.Action.changeset/2)
  end
end
