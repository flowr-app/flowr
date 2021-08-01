defmodule Flowr.Repo.Migrations.CreatePollings do
  use Ecto.Migration

  def change do
    create table(:pollings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :endpoint, :string, null: false
      add :customer_id, references(:customers, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:pollings, [:customer_id])
  end
end
