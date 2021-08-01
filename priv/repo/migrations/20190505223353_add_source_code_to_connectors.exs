defmodule Flowr.Repo.Migrations.AddSourceCodeToConnectors do
  use Ecto.Migration

  def change do
    alter table(:connectors) do
      add(:source_code, :text)
    end
  end
end
