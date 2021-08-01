defmodule Flowr.Repo.Migrations.RemoveNameOnSubscriptionsAndPollings do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      remove(:name)
    end

    alter table(:pollings) do
      remove(:name)
    end
  end
end
