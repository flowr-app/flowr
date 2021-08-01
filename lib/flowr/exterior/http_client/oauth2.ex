defmodule Flowr.Exterior.HTTPClient.OAuth2 do
  alias Flowr.Exterior
  alias Flowr.Exterior.Account

  require Logger

  @default_content_type "application/x-www-form-urlencoded"

  def get_token(%Account{} = account, code) do
    Logger.info("Getting the token for account: #{inspect(account)}")

    connector = Exterior.get_connector!(account.connector_id)

    config = connector.config
    Logger.info("Config: #{inspect(config)}")

    get_token_settings = connector.auth.connection_info["get_token"]

    Logger.info("get_token settings: #{inspect(get_token_settings)}")

    meta = Flowr.Exterior.Connector.Meta.for_oauth2(account)

    Logger.info("Meta: #{inspect(meta)}")

    headers =
      get_token_settings["headers"]
      |> Map.put_new("content-type", @default_content_type)
      |> Enum.map(&process_vars(&1, config, meta, %{code: code}))
      |> Enum.into(%{})

    Logger.info("Headers: #{inspect(headers)}")

    req_body =
      get_token_settings["body"]
      |> Enum.map(&process_vars(&1, config, meta, %{code: code}))
      |> Enum.into(%{})
      |> encode_body(headers["content-type"])

    Logger.info("Request body: #{inspect(req_body)}")

    with {:ok, %HTTPoison.Response{body: resp_body, status_code: 200}} <-
           HTTPoison.request(
             get_token_settings["method"],
             get_token_settings["url"],
             req_body,
             headers |> Map.to_list()
           ),
         {:ok, json} <- Jason.decode(resp_body) do
      {:ok, json}
    else
      {:ok, %HTTPoison.Response{body: resp_body, status_code: 400}} ->
        {:ok, json} = Jason.decode(resp_body)
        {:error, json}

      {:error, err} ->
        {:error, err}
    end
  end

  defp process_vars({key, value}, config, meta, input) when is_binary(value) do
    processed_value = EEx.eval_string(value, config: config, meta: meta, input: input)

    {key, processed_value}
  end

  defp process_vars({key, value}, config, meta, input) when is_map(value) do
    processed_value =
      value
      |> Enum.map(&process_vars(&1, config, meta, input))
      |> Enum.into(%{})

    {key, processed_value}
  end

  defp encode_body(body, "application/x-www-form-urlencoded") when is_map(body) do
    {:form, Map.to_list(body)}
  end

  defp encode_body(body, "application/json") when is_map(body) do
    Jason.encode_to_iodata!(body)
  end
end
