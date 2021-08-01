defmodule Flowr.Accounts.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "customers" do
    field :owner_id, :string
    field :access_token, :string
    field :access_token_expires_at, :naive_datetime
    field :account_info, :map
    field :refresh_token, :string
    field :refresh_token_expires_at, :naive_datetime

    has_many(:triggers, Flowr.Platform.Trigger)

    has_many(:flows, Flowr.Automation.Flow)
    has_many(:flow_tasks, Flowr.Automation.Task)

    has_many(:connector_accounts, Flowr.Exterior.Account)

    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :owner_id,
      :access_token,
      :refresh_token,
      :access_token_expires_at,
      :refresh_token_expires_at
    ])
  end

  def creation_changeset(customer, attrs) do
    changeset(customer, attrs)
    |> validate_required([
      :owner_id,
      :access_token,
      :refresh_token,
      :access_token_expires_at,
      :refresh_token_expires_at
    ])
    |> unique_constraint(:owner_id)
  end

  def updating_changeset(customer, attrs) do
    changeset(customer, attrs)
    |> validate_required([
      :access_token,
      :refresh_token,
      :access_token_expires_at,
      :refresh_token_expires_at
    ])
  end
end
