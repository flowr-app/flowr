defmodule Flowr.Repo.Migrations.CreateConnectorAccounts do
  use Ecto.Migration

  def change do
    create table(:connector_accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :credentials, :map, null: false
      add :auth_type, :string, null: false

      add :connector_id, references(:connectors, on_delete: :nothing, type: :binary_id),
        null: false

      add :customer_id, references(:customers, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:connector_accounts, [:connector_id])
    create index(:connector_accounts, [:customer_id])
    create index(:connector_accounts, [:customer_id, :connector_id])
  end
end
