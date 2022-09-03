defmodule Flowr.Platform.OAuth do
  alias Flowr.Platform.Client

  def client do
    Client.oauth_client()
  end

  def get_authorize_url do
    RingCentral.OAuth.authorize(client(), %{response_type: "code", redirect_uri: redirect_url()})
  end

  def get_token(code) do
    RingCentral.OAuth.get_token(client(), %{
      grant_type: "authorization_code",
      code: code,
      redirect_uri: redirect_url()
    })
  end

  def refresh_token(refresh_token) do
    RingCentral.OAuth.get_token(client(), %{
      grant_type: "refresh_token",
      refresh_token: refresh_token
    })
  end

  defp redirect_url do
    FlowrWeb.Router.Helpers.auth_url(FlowrWeb.Endpoint, :callback)
  end
end
