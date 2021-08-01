defmodule Flowr.Repo.Migrations.RemoveConnectorAccountsAuthType do
  use Ecto.Migration

  def change do
    alter table(:connector_accounts) do
      remove(:auth_type)
    end
  end
end
