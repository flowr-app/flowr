defmodule Flowr.Repo.Migrations.AddAuthToConnectors do
  use Ecto.Migration

  def change do
    alter table(:connectors) do
      add :auth, :map
    end
  end
end
