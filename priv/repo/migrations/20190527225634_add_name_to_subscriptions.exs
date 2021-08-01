defmodule Flowr.Repo.Migrations.AddNameToSubscriptions do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add(:name, :string)
    end
  end
end
