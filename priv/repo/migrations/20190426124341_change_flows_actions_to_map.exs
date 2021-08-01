defmodule Flowr.Repo.Migrations.ChangeFlowsActionsToMap do
  use Ecto.Migration

  def up do
    alter table(:flows) do
      remove :actions
    end

    alter table(:flows) do
      add :actions, :map
    end
  end

  def down do
    alter table(:flows) do
      remove :actions
    end

    alter table(:flows) do
      add :actions, {:array, :string}
    end
  end
end
