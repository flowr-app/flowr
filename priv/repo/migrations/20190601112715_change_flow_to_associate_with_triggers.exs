defmodule Flowr.Repo.Migrations.ChangeFlowToAssociateWithTriggers do
  use Ecto.Migration

  def change do
    alter table(:flows) do
      remove(:subscription_id)

      add :trigger_id, references(:triggers, on_delete: :nothing, type: :binary_id)
    end
  end
end
