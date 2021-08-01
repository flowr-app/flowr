defmodule Flowr.Automation.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @status ~w(pending running success failed)

  schema "flow_tasks" do
    field :status, :string, default: "pending"
    field :input_data, :map

    belongs_to(:flow, Flowr.Automation.Flow)
    belongs_to(:customer, Flowr.Accounts.Customer)

    timestamps()
  end

  @doc false
  def creation_changeset(task, attrs) do
    task
    |> cast(attrs, [:input_data, :customer_id])
    |> validate_required([:input_data, :customer_id])
  end

  def updating_changeset(task, attrs) do
    task
    |> cast(attrs, [:status])
    |> validate_required([:status])
    |> validate_inclusion(:status, @status)
  end
end
