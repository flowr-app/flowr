defmodule Flowr.Repo.Migrations.AddFunctionsToConnectors do
  use Ecto.Migration

  def change do
    alter table(:connectors) do
      add :functions, {:array, :string}, default: []
    end
  end
end
