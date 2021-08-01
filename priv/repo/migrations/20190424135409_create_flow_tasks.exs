defmodule Flowr.Repo.Migrations.CreateFlowTasks do
  use Ecto.Migration

  def change do
    create table(:flow_tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string, null: false

      add :flow_id, references(:flows, on_delete: :nothing, type: :binary_id), null: false

      add :subscription_log_id,
          references(:subscription_logs, on_delete: :nothing, type: :binary_id),
          null: false

      add :subscription_id,
          references(:subscriptions, on_delete: :nothing, type: :binary_id),
          null: false

      add :customer_id,
          references(:customers, on_delete: :nothing, type: :binary_id),
          null: false

      timestamps()
    end

    create index(:flow_tasks, [:flow_id])
    create index(:flow_tasks, [:subscription_log_id])
    create index(:flow_tasks, [:subscription_id])
    create index(:flow_tasks, [:customer_id])
    create unique_index(:flow_tasks, [:flow_id, :subscription_log_id])
  end
end
