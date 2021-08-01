defmodule Flowr.Repo.Migrations.ChangeConnectorsFunctionsToEmbed do
  use Ecto.Migration

  def up do
    alter table(:connectors) do
      remove(:functions)
      add(:functions, {:array, :map})
    end
  end

  def down do
    alter table(:connectors) do
      remove(:functions)
      add(:functions, {:array, :string})
    end
  end
end
