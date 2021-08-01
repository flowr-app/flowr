defmodule Flowr.Repo.Migrations.CreateFlows do
  use Ecto.Migration

  def change do
    create table(:flows, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :actions, {:array, :string}, default: []

      add :subscription_id, references(:subscriptions, on_delete: :nothing, type: :binary_id),
        null: false

      add :customer_id, references(:customers, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:flows, [:subscription_id])
    create index(:flows, [:customer_id])
    create index(:flows, [:customer_id, :subscription_id])
  end
end
