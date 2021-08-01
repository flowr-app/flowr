defmodule Flowr.Repo.Migrations.AddConfigToConnectors do
  use Ecto.Migration

  def change do
    alter table(:connectors) do
      add :config, :map
    end
  end
end
