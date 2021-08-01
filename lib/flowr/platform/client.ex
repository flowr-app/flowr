defmodule Flowr.Platform.Client do
  @spec rest_client(binary) :: RingCentral.t()
  def rest_client(access_token) do
    RingCentral.build(
      client_id: client_id(),
      client_secret: client_secret(),
      server_url: server_url(),
      token_info: %{
        "access_token" => access_token
      }
    )
  end

  @spec oauth_client :: RingCentral.t()
  def oauth_client do
    RingCentral.build(
      client_id: client_id(),
      client_secret: client_secret(),
      server_url: server_url()
    )
  end

  defp client_id do
    System.get_env("RC_CLIENT_ID")
  end

  defp client_secret do
    System.get_env("RC_CLIENT_SECRET")
  end

  defp server_url do
    System.get_env("RC_SERVER_URL", "https://platform.devtest.ringcentral.com")
  end
end
