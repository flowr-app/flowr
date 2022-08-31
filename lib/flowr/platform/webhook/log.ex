defmodule Flowr.Platform.Webhook.Log do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "webhook_logs" do
    field :payload, :map

    belongs_to(:webhook, Flowr.Platform.Webhook)

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:payload])
    |> validate_required([:payload])
  end
end
