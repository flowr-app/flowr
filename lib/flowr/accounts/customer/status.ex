defmodule Flowr.Accounts.Customer.Status do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :active?, :boolean, default: true

    timestamps(inserted_at: false)
  end

  def changeset(customer_status, attrs) do
    customer_status
    |> cast(attrs, [:active?])
  end
end
