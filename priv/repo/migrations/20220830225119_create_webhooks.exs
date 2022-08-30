defmodule Flowr.Repo.Migrations.CreateWebhooks do
  use Ecto.Migration

  def change do
    create table(:webhooks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :endpoint_id, :string, null: false

      add :trigger_id, references(:triggers, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:webhooks, :trigger_id)
    create unique_index(:webhooks, :endpoint_id)
  end
end
