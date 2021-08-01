defmodule Flowr.Platform.Subscription.Log do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subscription_logs" do
    field :info, :map

    belongs_to(:subscription, Flowr.Platform.Subscription)

    timestamps()
  end

  @doc false
  def changeset(subscription_log, attrs) do
    subscription_log
    |> cast(attrs, [:info])
    |> validate_required([:info])
  end
end
