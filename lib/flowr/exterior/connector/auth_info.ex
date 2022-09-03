defmodule Flowr.Exterior.Connector.AuthInfo do
  @moduledoc """
  %{
    auth_type: "oauth2",
    connection_info: %{
      "authorize": {
        method: 'GET'
        headers: [],
        body:
      }
    }
  }
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @primary_key false

  embedded_schema do
    field :auth_type, :string
    field :connection_info, :map
  end

  @doc false
  def changeset(auth, attrs) do
    auth
    |> cast(filter(attrs), [:auth_type, :connection_info])
    |> validate_required([:auth_type, :connection_info])
    |> validate_inclusion(:auth_type, Flowr.Exterior.AuthType.auth_types())
    |> validate_connection_info_schema()
  end

  defp filter(%{"connection_info" => connection_info} = params) do
    params
    |> Map.put("connection_info", Jason.decode!(connection_info))
  end

  defp filter(params), do: params

  defp validate_connection_info_schema(changeset) do
    auth_type = get_field(changeset, :auth_type)
    json_schema = get_json_schema(auth_type)

    validate_change(changeset, :connection_info, fn :connection_info, connection_info ->
      case JsonXema.validate(json_schema, connection_info) do
        :ok -> []
        {:error, err} -> [connection_info: Jason.encode!(err)]
      end
    end)
  end

  defp get_json_schema("oauth2") do
    ~s"""
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "type": "object",
      "properties": {
        "authorize": {
          "type": "object",
          "properties": {
            "url": {
              "type": "string"
            },
            "params": {
              "type": "object"
            }
          },
          "required": ["url"]
        },
        "get_token": {
          "type": "object",
          "properties": {
            "url": {
              "type": "string"
            },
            "method": {
              "type": "string"
            },
            "params": {
              "type": "object"
            },
            "body": {
              "type": "object"
            },
            "headers": {
              "type": "object"
            }
          },
          "required": ["url", "method"]
        }
      },
      "required": ["authorize", "get_token"]
    }
    """
    |> Jason.decode!()
    |> JsonXema.new()
  end
end
