defmodule Flowr.Repo.Migrations.MakeFlowTasksAwareTrigger do
  use Ecto.Migration

  def change do
    alter table(:flow_tasks) do
      remove(:subscription_id)
      remove(:subscription_log_id)

      add :input_data, :map
    end
  end
end
