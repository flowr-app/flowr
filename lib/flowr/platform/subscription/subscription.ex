defmodule Flowr.Platform.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "subscriptions" do
    field :event_type, :string
    field :subscription_info, :map, default: %{}
    field :verification_token, :string

    belongs_to(:trigger, Flowr.Platform.Trigger)
    has_many(:logs, Flowr.Platform.Subscription.Log, foreign_key: :subscription_id)

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:event_type, :subscription_info])
    |> validate_required([:event_type, :subscription_info])
  end

  @doc false
  def creation_changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:event_type])
    |> validate_required([:event_type])
    |> generate_verification_token()
  end

  defp generate_verification_token(changeset) do
    changeset
    |> put_change(:verification_token, Ecto.UUID.generate())
  end
end
