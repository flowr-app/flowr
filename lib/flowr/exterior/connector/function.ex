defmodule Flowr.Exterior.Connector.Function do
  @moduledoc """
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  embedded_schema do
    field :name, :string

    field :arg_template, :map,
      default: %{
        "file" => %{
          "name" => "{NAME}",
          "uri" => "{URI}"
        }
      }
  end

  @doc false
  def changeset(auth, attrs) do
    auth
    |> cast(filter(attrs), [:name, :arg_template])
    |> validate_required([:name, :arg_template])
  end

  defp filter(%{"arg_template" => arg_template} = params) do
    params
    |> Map.put("arg_template", Jason.decode!(arg_template))
  end

  defp filter(params), do: params
end
