defmodule Flowr.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_type, :string, null: false
      add :verification_token, :string, null: false
      add :subscription_info, :map, null: false

      add :customer_id, references(:customers, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create index(:subscriptions, :customer_id)
  end
end
