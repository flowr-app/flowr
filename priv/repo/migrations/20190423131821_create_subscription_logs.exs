defmodule Flowr.Repo.Migrations.CreateSubscriptionLogs do
  use Ecto.Migration

  def change do
    create table(:subscription_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :info, :map, null: false

      add :subscription_id, references(:subscriptions, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:subscription_logs, [:subscription_id])
  end
end
