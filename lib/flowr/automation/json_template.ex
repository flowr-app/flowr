defmodule Flowr.Automation.JSONTemplate do
  def parse(template, params) do
    data =
      template
      |> Enum.map(&do_parse(&1, params))
      |> Enum.into(%{})

    {:ok, data}
  end

  defp do_parse({key, value}, params) when is_binary(value) do
    expression_pattern = ~r/{(?<json_path>.*)}/
    capture = Regex.named_captures(expression_pattern, value)

    case capture do
      nil ->
        {key, value}

      %{"json_path" => json_path} ->
        replaced_json_path_value = extract_value(json_path, params)
        {key, Regex.replace(expression_pattern, value, replaced_json_path_value)}
    end
  end

  defp do_parse({key, value}, params) when is_map(value) do
    parsed_value =
      value
      |> Enum.map(&do_parse(&1, params))
      |> Enum.into(%{})

    {key, parsed_value}
  end

  defp extract_value(value, params) do
    stream =
      Jason.encode!(params)
      |> Jaxon.Stream.from_binary()

    json_path = Jaxon.Path.parse!(value)
    result = Jaxon.Stream.query(stream, json_path)

    case Enum.to_list(result) do
      [] ->
        ""

      [v | _] ->
        v
    end
  end
end
