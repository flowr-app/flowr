defmodule Flowr.Repo.Migrations.AddAdapterNameToConnectors do
  use Ecto.Migration

  def change do
    alter table(:connectors) do
      add :adapter_name, :string, default: "dynamic"
    end
  end
end
