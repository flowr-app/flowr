defmodule Flowr.Repo.Migrations.CreatePollingItems do
  use Ecto.Migration

  def change do
    create table(:polling_items, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :data, :map, null: false
      add :item_id, :string, null: false
      add :polling_id, references(:pollings, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:polling_items, [:polling_id])
    create unique_index(:polling_items, [:polling_id, :item_id])
  end
end
