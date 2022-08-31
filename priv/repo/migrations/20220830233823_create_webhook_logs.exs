defmodule Flowr.Repo.Migrations.CreateWebhookLogs do
  use Ecto.Migration

  def change do
    create table(:webhook_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :payload, :map, null: false

      add :webhook_id, references(:webhooks, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:webhook_logs, [:webhook_id])
  end
end
