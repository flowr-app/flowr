defmodule Flowr.Platform.Webhook do
  defmodule RandomStringGenerator do
    @length 25

    @spec generate :: binary
    def generate do
      :crypto.strong_rand_bytes(@length)
      |> Base.url_encode64()
      |> binary_part(0, @length)
    end
  end

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "webhooks" do
    field :endpoint_id, :string,
      autogenerate: {Flowr.Platform.Webhook.RandomStringGenerator, :generate, []}

    belongs_to :trigger, Flowr.Platform.Trigger
    has_many :logs, Flowr.Platform.Webhook.Log, foreign_key: :webhook_id

    timestamps()
  end

  @doc false
  def creation_changeset(webhook, _attrs) do
    webhook
    |> change()
  end
end
