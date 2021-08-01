defmodule Flowr.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :owner_id, :string, null: false
      add :account_info, :map
      add :access_token, :text, null: false
      add :refresh_token, :text, null: false
      add :access_token_expires_at, :naive_datetime, null: false
      add :refresh_token_expires_at, :naive_datetime, null: false

      timestamps()
    end

    create unique_index(:customers, [:owner_id])
  end
end
