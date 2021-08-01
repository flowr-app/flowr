defmodule Flowr.Repo.Migrations.AddDescriptionToConnectors do
  use Ecto.Migration

  def change do
    alter table(:connectors) do
      add(:description, :text)
    end
  end
end
