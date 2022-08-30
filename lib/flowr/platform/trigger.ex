defmodule Flowr.Platform.Trigger do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @categories ~w(subscription polling webhook)

  schema "triggers" do
    field :name, :string
    field :category, :string

    has_one(:polling, Flowr.Platform.Polling)
    has_one(:subscription, Flowr.Platform.Subscription)
    has_one(:webhook, Flowr.Platform.Webhook)
    belongs_to(:customer, Flowr.Accounts.Customer)
    has_many(:flows, Flowr.Automation.Flow)

    timestamps()
  end

  @doc false
  def categories do
    @categories
  end

  @doc false
  def changeset(trigger, attrs) do
    trigger
    |> cast(attrs, [:name, :category])
    |> validate_inclusion(:category, @categories)
    |> cast_assoc(:subscription, with: &Flowr.Platform.Subscription.creation_changeset/2)
    |> cast_assoc(:polling)
    |> cast_assoc(:webhook, with: &Flowr.Platform.Webhook.creation_changeset/2)
  end
end
