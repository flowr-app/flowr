defmodule Flowr.Exterior.Connector.Builtin.Dropbox do
  require Logger
  use Flowr.Exterior.Connector.Behaviour, :builtin

  def id do
    "dropbox"
  end

  @impl true
  def auth_info do
    %{
      auth_type: "oauth2",
      connection_info: %{
        "authorize" => %{
          "params" => %{
            "client_id" => "<%= config[\"app_key\"] %>",
            "redirect_uri" => "<%= meta.redirect_uri %>",
            "response_type" => "code",
            "state" => "<%= meta.state %>"
          },
          "url" => "https://www.dropbox.com/oauth2/authorize"
        },
        "get_token" => %{
          "body" => %{
            "client_id" => "<%= config[\"app_key\"] %>",
            "client_secret" => "<%= config[\"app_secret\"] %>",
            "code" => "<%= input.code %>",
            "grant_type" => "authorization_code",
            "redirect_uri" => "<%= meta.redirect_uri %>"
          },
          "headers" => %{"content-type" => "application/x-www-form-urlencoded"},
          "method" => "POST",
          "url" => "https://api.dropboxapi.com/oauth2/token"
        }
      }
    }
  end

  @impl true
  def config do
    %{
      app_key: "DROPBOX_APP_KEY",
      app_secret: "DROPBOX_APP_SECRET"
    }
  end

  @impl true
  def functions do
    [
      %{
        name: "upload_file",
        arg_template: %{
          "file" => %{
            "path" => "{PATH}",
            "content" => "{CONTENT}"
          }
        }
      }
    ]
  end

  @impl true
  def run(
        "upload_file",
        _config,
        _meta,
        credentials,
        %{
          "file" => %{
            "path" => path,
            "content" => content
          }
        }
      ) do
    Logger.info("Connector Dropbox running:")

    req_args =
      %{
        "path" => path,
        "mode" => "add",
        "autorename" => true,
        "mute" => false,
        "strict_conflict" => false
      }
      |> Jason.encode!()

    headers = [
      {"authorization", "Bearer " <> credentials["access_token"]},
      {"Dropbox-API-Arg", req_args},
      {"Content-Type", "application/octet-stream"}
    ]

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(
             "https://content.dropboxapi.com/2/files/upload",
             content,
             headers
           ),
         {:ok, json} <- Jason.decode(body) do
      {:ok, json}
    end
  end

  def run(_function, _config, _meta, _credentials, args) do
    {:error, %{"message" => "Unexpected args", "args" => inspect(args)}}
  end
end
