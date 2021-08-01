defmodule Flowr.Repo.Migrations.CreateTriggers do
  use Ecto.Migration

  def change do
    create table(:triggers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :category, :string, null: false

      add :subscription_id, references(:subscriptions, on_delete: :nothing, type: :binary_id)

      add :polling_id, references(:pollings, on_delete: :nothing, type: :binary_id)
      add :customer_id, references(:customers, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:triggers, [:subscription_id])
    create index(:triggers, [:polling_id])
    create index(:triggers, [:customer_id])
  end
end
