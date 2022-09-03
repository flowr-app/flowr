defmodule Flowr.Exterior.Connector do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "connectors" do
    field :name, :string
    field :description, :string
    field :adapter_name, :string, default: Flowr.Automation.Runner.Adapter.default_adapter()

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

  def get_functions(%__MODULE__{
        adapter_name: "builtin",
        run_info: %{builtin_connector_id: builtin_connector_id}
      }) do
    builtin_connector_id
    |> Flowr.Exterior.Connector.Builtin.get_connector_module()
    |> apply(:functions, [])
  end

  def get_functions(%__MODULE__{adapter_name: _} = connector) do
    connector.functions
  end

  @doc false
  def changeset(connector, attrs) do
    connector
    |> cast(filter(attrs), [:name, :adapter_name, :config, :description])
    |> validate_required([:name, :config])
    |> validate_inclusion(:adapter_name, Flowr.Automation.Runner.Adapter.adapters())
    |> cast_embed(:auth, with: &Flowr.Exterior.Connector.AuthInfo.changeset/2, required: false)
    |> cast_embed(:run_info, with: &Flowr.Exterior.Connector.RunInfo.changeset/2, required: true)
    |> cast_embed(:functions, with: &Flowr.Exterior.Connector.Function.changeset/2)
  end

  defp filter(%{"config" => config} = params) do
    params
    |> Map.put("config", Jason.decode!(config))
  end

  defp filter(params), do: params
end
