defmodule Flowr.Repo.Migrations.AddRunInfoToConnectors do
  use Ecto.Migration

  def up do
    alter table(:connectors) do
      remove(:source_code)
      add(:run_info, :map)
    end
  end

  def down do
    alter table(:connectors) do
      remove(:run_info)
      add(:source_code, :text)
    end
  end
end
