defmodule Flowr.Automation do
  @moduledoc """
  The Automation context.
  """

  import Ecto.Query, warn: false
  alias Flowr.Repo

  alias Flowr.Automation.Flow
  alias Flowr.Automation.Action
  alias Flowr.Automation.JSONTemplate

  @doc """
  Returns the list of flows.

  ## Examples

      iex> list_flows()
      [%Flow{}, ...]

  """
  def list_flows do
    Repo.all(Flow)
  end

  def list_flows(%Flowr.Accounts.Customer{} = customer) do
    customer
    |> Ecto.assoc(:flows)
    |> Repo.all()
  end

  def list_flows(%Flowr.Platform.Trigger{} = trigger) do
    trigger
    |> Ecto.assoc(:flows)
    |> Repo.all()
  end

  @doc """
  Gets a single flow.

  Raises `Ecto.NoResultsError` if the Flow does not exist.

  ## Examples

      iex> get_flow!(123)
      %Flow{}

      iex> get_flow!(456)
      ** (Ecto.NoResultsError)

  """
  def get_flow!(id), do: Repo.get!(Flow, id)

  @doc """
  Creates a flow.

  ## Examples

      iex> create_flow(%{field: value})
      {:ok, %Flow{}}

      iex> create_flow(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_flow(customer, attrs \\ %{}) do
    customer
    |> Ecto.build_assoc(:flows)
    |> Flow.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a flow.

  ## Examples

      iex> update_flow(flow, %{field: new_value})
      {:ok, %Flow{}}

      iex> update_flow(flow, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_flow(%Flow{} = flow, attrs) do
    flow
    |> Flow.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Flow.

  ## Examples

      iex> delete_flow(flow)
      {:ok, %Flow{}}

      iex> delete_flow(flow)
      {:error, %Ecto.Changeset{}}

  """
  def delete_flow(%Flow{} = flow) do
    Repo.delete(flow)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking flow changes.

  ## Examples

      iex> change_flow(flow)
      %Ecto.Changeset{source: %Flow{}}

  """
  def change_flow(%Flow{} = flow) do
    Flow.changeset(flow, %{})
  end

  def change_flow(%Flow{} = flow, attrs) do
    Flow.changeset(flow, attrs)
  end

  alias Flowr.Automation.Task

  @doc """
  Returns the list of flow_tasks.

  ## Examples

      iex> list_flow_tasks()
      [%Task{}, ...]

  """
  def list_flow_tasks(%Flow{} = flow) do
    query =
      from t in Ecto.assoc(flow, :tasks),
        order_by: [desc: :inserted_at]

    query
    |> Repo.all()
  end

  def list_flow_tasks(%Flowr.Accounts.Customer{} = customer) do
    query =
      from t in Ecto.assoc(customer, :flow_tasks),
        preload: [:flow],
        order_by: [desc: :inserted_at]

    query
    |> Repo.all()
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  def run_task(%Task{} = task) do
    task =
      task
      |> Repo.preload([:flow])

    task.flow.actions
    |> Enum.reduce_while(task.input_data, fn action, acc ->
      case run_action(action, acc) do
        {:ok, result} -> {:cont, result}
        {:error, error} -> {:halt, error}
      end
    end)
  end

  def run_action(%Action{} = action, params) do
    {:ok, args} = JSONTemplate.parse(action.args_template, params)

    Flowr.Automation.Runner.run_action(action, args)
  end

  def finish_task(%Task{} = task, status, result_info) do
    task
    |> Task.updating_changeset(%{status: status, result_info: result_info})
    |> Repo.update()
  end

  def change_action(%Action{} = action) do
    Action.changeset(action, %{})
  end
end
