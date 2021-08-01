defmodule :"Elixir.Flowr.Repo.Migrations.One-on-one-assoc-for-triggers" do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add :trigger_id, references(:triggers, on_delete: :nothing, type: :binary_id)
      remove :customer_id
    end

    alter table(:pollings) do
      add :trigger_id, references(:triggers, on_delete: :nothing, type: :binary_id)
      remove :customer_id
    end

    alter table(:triggers) do
      remove(:polling_id)
      remove(:subscription_id)
    end
  end
end
