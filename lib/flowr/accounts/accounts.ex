defmodule Flowr.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Flowr.Repo

  alias Flowr.Accounts.Customer

  def list_customers(query, opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)

    query =
      from q in query,
        limit: ^limit

    Repo.all(query)
  end

  @doc """
  Gets a single customer.

  Raises `Ecto.NoResultsError` if the Customer does not exist.

  ## Examples

      iex> get_customer!(123)
      %Customer{}

      iex> get_customer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_customer!(id), do: Repo.get!(Customer, id)

  def create_customer_from_oauth_token(token) do
    attrs = %{
      owner_id: token["owner_id"],
      access_token: token["access_token"],
      access_token_expires_at:
        NaiveDateTime.add(
          NaiveDateTime.utc_now(),
          token["expires_in"],
          :second
        ),
      refresh_token: token["refresh_token"],
      refresh_token_expires_at:
        NaiveDateTime.add(
          NaiveDateTime.utc_now(),
          token["refresh_token_expires_in"],
          :second
        ),
      status: %{
        active?: true
      }
    }

    %Customer{}
    |> Customer.creation_changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace_all_except, [:id, :owner_id]},
      conflict_target: :owner_id,
      returning: true
    )
  end

  @doc """
  Updates a customer.

  ## Examples

      iex> update_customer(customer, %{field: new_value})
      {:ok, %Customer{}}

      iex> update_customer(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Customer.

  ## Examples

      iex> delete_customer(customer)
      {:ok, %Customer{}}

      iex> delete_customer(customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking customer changes.

  ## Examples

      iex> change_customer(customer)
      %Ecto.Changeset{source: %Customer{}}

  """
  def change_customer(%Customer{} = customer) do
    Customer.changeset(customer, %{})
  end

  def refresh_token(%Customer{refresh_token: refresh_token} = customer) do
    Repo.transaction(fn ->
      with {:ok, token} <-
             Flowr.Platform.OAuth.refresh_token(refresh_token),
           {:ok, customer} <- update_customer_from_oauth(customer, token) do
        {:ok, customer}
      else
        {:error, %RingCentral.Error{code: :client_error, detail: %{status: status, data: _data}}}
        when status in [400] ->
          # refresh token is invalid, gave up refresh, and mark customer as inactive
          {:ok, _} = update_customer_status(customer, %{active?: false})
      end
    end)
  end

  def update_customer_from_oauth(customer, token) do
    attrs = %{
      access_token: token["access_token"],
      access_token_expires_at:
        NaiveDateTime.add(
          NaiveDateTime.utc_now(),
          token["expires_in"],
          :second
        ),
      refresh_token: token["refresh_token"],
      refresh_token_expires_at:
        NaiveDateTime.add(
          NaiveDateTime.utc_now(),
          token["refresh_token_expires_in"],
          :second
        )
    }

    customer
    |> Customer.updating_changeset(attrs)
    |> Repo.update()
  end

  def update_customer_status(customer, status_attrs) do
    customer
    |> Customer.status_changeset(%{"status" => status_attrs})
    |> Repo.update()
  end
end
