defmodule Flowr.Exterior.Connector do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "connectors" do
    field :name, :string
    field :description, :string

    field :config, :map,
      default: %{
        app_key: "APP_KEY",
        app_secret: "APP_SECRET"
      }

    embeds_one(:auth, Flowr.Exterior.Connector.AuthInfo, on_replace: :update)
    embeds_one(:run_info, Flowr.Exterior.Connector.RunInfo, on_replace: :update)
    embeds_many(:functions, Flowr.Exterior.Connector.Function, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(connector, attrs) do
    connector
    |> cast(filter(attrs), [:name, :config, :description])
    |> validate_required([:name, :config])
    |> cast_embed(:auth, with: &Flowr.Exterior.Connector.AuthInfo.changeset/2, required: true)
    |> cast_embed(:run_info, with: &Flowr.Exterior.Connector.RunInfo.changeset/2, required: true)
    |> cast_embed(:functions, with: &Flowr.Exterior.Connector.Function.changeset/2)
  end

  defp filter(%{"config" => config} = params) do
    params
    |> Map.put("config", Jason.decode!(config))
  end

  defp filter(params), do: params
end
