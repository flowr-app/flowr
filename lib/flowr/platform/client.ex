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
    app_config()[:client_id]
  end

  defp client_secret do
    app_config()[:client_secret]
  end

  defp server_url do
    app_config()[:server_url]
  end

  defp app_config do
    Application.get_env(:flowr, Flowr.Platform.Client)
  end
end
