defmodule Flowr.Repo.Migrations.AddStatusToCustomers do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add :status, :map, default: %{active?: true}
    end
  end
end
