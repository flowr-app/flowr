defmodule Flowr.Exterior do
  @moduledoc """
  The Exterior context.
  """
  require Logger

  import Ecto.Query, warn: false
  alias Flowr.Repo

  alias Flowr.Exterior.Connector

  @doc """
  Returns the list of connectors.

  ## Examples

      iex> list_connectors()
      [%Connector{}, ...]

  """
  def list_connectors do
    Repo.all(Connector)
  end

  @doc """
  Gets a single connector.

  Raises `Ecto.NoResultsError` if the Connector does not exist.

  ## Examples

      iex> get_connector!(123)
      %Connector{}

      iex> get_connector!(456)
      ** (Ecto.NoResultsError)

  """
  def get_connector!(id), do: Repo.get!(Connector, id)

  @doc """
  Creates a connector.

  ## Examples

      iex> create_connector(%{field: value})
      {:ok, %Connector{}}

      iex> create_connector(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_connector(attrs \\ %{}) do
    %Connector{}
    |> Connector.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a connector.

  ## Examples

      iex> update_connector(connector, %{field: new_value})
      {:ok, %Connector{}}

      iex> update_connector(connector, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_connector(%Connector{} = connector, attrs) do
    connector
    |> Connector.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Connector.

  ## Examples

      iex> delete_connector(connector)
      {:ok, %Connector{}}

      iex> delete_connector(connector)
      {:error, %Ecto.Changeset{}}

  """
  def delete_connector(%Connector{} = connector) do
    Repo.delete(connector)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking connector changes.

  ## Examples

      iex> change_connector(connector)
      %Ecto.Changeset{source: %Connector{}}

  """
  def change_connector(%Connector{} = connector, args \\ %{}) do
    Connector.changeset(connector, args)
  end

  alias Flowr.Exterior.Account

  @doc """
  Returns the list of connector_accounts.

  ## Examples

      iex> list_connector_accounts()
      [%Account{}, ...]

  """
  def list_accounts(customer) do
    customer
    |> Ecto.assoc(:connector_accounts)
    |> Repo.all()
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(customer, attrs \\ %{}) do
    customer
    |> Ecto.build_assoc(:connector_accounts)
    |> Account.creation_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{source: %Account{}}

  """
  def change_account(%Account{} = account) do
    Account.changeset(account, %{})
  end

  def get_auth_url(account) do
    # TODO: handle auth other than oauth2

    connector = Flowr.Exterior.get_connector!(account.connector_id)
    base_url = connector.auth.connection_info["authorize"]["url"]

    meta = Flowr.Exterior.Connector.Meta.for_oauth2(account)

    query_params =
      connector.auth.connection_info["authorize"]["params"]
      |> Enum.map(&process_vars(&1, connector.config, meta))
      |> Enum.into(%{})
      |> URI.encode_query()

    base_url
    |> URI.merge("?#{query_params}")
    |> to_string()
  end

  defp process_vars({key, value}, config, meta) do
    # TODO: Extract to a helper module,
    # and use a custom EEx engine or a JSON template engine.
    processed_value = EEx.eval_string(value, config: config, meta: meta)

    {key, processed_value}
  end

  def change_function(%Flowr.Exterior.Connector.Function{} = function) do
    Flowr.Exterior.Connector.Function.changeset(function, %{})
  end
end
