defmodule Flowr.Exterior.Connector.Dynamic do
  def default_connector_params() do
    %{
      adapter_name: "dynamic",
      auth: %Flowr.Exterior.Connector.AuthInfo{
        auth_type: "oauth2",
        connection_info: %{
          "authorize" => %{
            "url" => "https://www.dropbox.com/oauth2/authorize",
            "params" => %{
              "client_id" => "<%= config[\"app_key\"] %>",
              "redirect_uri" => "<%= meta.redirect_uri %>",
              "response_type" => "code",
              "state" => "<%= meta.state %>"
            }
          },
          "get_token" => %{
            "url" => "https://api.dropboxapi.com/oauth2/token",
            "method" => "POST",
            "body" => %{
              "code" => "<%= input.code %>",
              "grant_type" => "authorization_code",
              "client_id" => "<%= config[\"app_key\"] %>",
              "client_secret" => "<%= config[\"app_secret\"] %>",
              "redirect_uri" => "<%= meta.redirect_uri %>"
            },
            "headers" => %{
              "content-type" => "application/x-www-form-urlencoded"
            }
          }
        }
      },
      config: %{
        template_config: true,
        app_key: "APP_KEY",
        app_secret: "APP_SECRET"
      }
    }
  end
end
