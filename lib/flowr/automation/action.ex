defmodule Flowr.Automation.Action do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  embedded_schema do
    field :args_template, :map, default: %{}
    field :function, :string

    belongs_to(:account, Flowr.Exterior.Account)
    belongs_to(:connector, Flowr.Exterior.Connector)
  end

  @doc false
  def changeset(action, attrs) do
    action
    |> cast(filter(attrs), [:args_template, :function, :connector_id, :account_id])
    |> validate_required([:args_template, :function, :connector_id, :account_id])
  end

  defp filter(%{"args_template" => args_template} = params) when is_binary(args_template) do
    with {:ok, v} <- Jason.decode(args_template) do
      Map.put(params, "args_template", v)
    else
      _ ->
        params
    end
  end

  defp filter(params), do: params
end
