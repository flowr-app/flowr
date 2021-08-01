defmodule Flowr.Exterior.Connector.Meta do
  @type oauth2_t :: %{redirect_uri: binary(), state: binary()}
  @type run_t :: %{optional(binary()) => any}

  @spec for_oauth2(Flowr.Exterior.Account.t()) :: oauth2_t
  def for_oauth2(%Flowr.Exterior.Account{} = account) do
    %{
      redirect_uri: FlowrWeb.Router.Helpers.api_connector_account_url(FlowrWeb.Endpoint, :callback),
      state: account.id
    }
  end

  @spec for_run() :: run_t
  def for_run() do
    # TODO
    %{}
  end
end
