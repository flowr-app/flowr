defmodule FlowrWeb.Helpers.FormHelper do
  alias PhoenixBootstrapForm, as: PBF

  @doc false
  def json_textarea(form, field, opts \\ []) do
    value =
      form.source
      |> Ecto.Changeset.get_field(field)
      |> Jason.encode!(pretty: true)

    input_opts =
      [value: value]
      |> Keyword.merge(opts)

    PBF.textarea(form, field, input: input_opts)
  end

  def list_string_text_input(form, field) do
    value = form.source |> Ecto.Changeset.get_field(field) |> Enum.join(",")
    PBF.text_input(form, field, value: value)
  end
end
