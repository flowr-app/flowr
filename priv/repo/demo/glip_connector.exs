{:ok, glip_connector} =
  Flowr.Exterior.create_connector(%{
    name: "Glip (Example)",
    description: "Example: Glip",
    auth: %{
      auth_type: "oauth2",
      connection_info: %{
        "authorize" => %{
          "params" => %{
            "client_id" => "<%= config[\"client_id\"] %>",
            "redirect_uri" => "<%= meta.redirect_uri %>",
            "response_type" => "code",
            "state" => "<%= meta.state %>"
          },
          "url" => "https://platform.devtest.ringcentral.com/restapi/oauth/authorize"
        },
        "get_token" => %{
          "body" => %{
            "code" => "<%= input.code %>",
            "grant_type" => "authorization_code",
            "redirect_uri" => "<%= meta.redirect_uri %>"
          },
          "headers" => %{
            "authorization" => "Basic <%= config[\"authorization\"] %>",
            "content-type" => "application/x-www-form-urlencoded"
          },
          "method" => "POST",
          "url" => "https://platform.devtest.ringcentral.com/restapi/oauth/token"
        }
      }
    },
    run_info: %{
      adapter: "local",
      source_code: ~S"""
      defmodule Flowr.Connector.Glip do
        require Logger

        @behaviour Flowr.Exterior.Connector.Behaviour

        @functions ~w(create_post)

        @impl true
        def functions() do
          @functions
        end

        @impl true
        def run(
                "create_post",
                _config,
                _meta,
                credentials,
                %{
                  "text" => text,
                  "chat_id" => chat_id,
                }
            ) do

          Logger.info("Connector Glip running:")

          body =
            %{
              "text" => text
            }
            |> Jason.encode!()

          headers = [
            {"authorization", "Bearer " <> credentials["access_token"]},
            {"Content-Type", "application/json"}
          ]

          with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
                 HTTPoison.post(
                   "https://platform.devtest.ringcentral.com/restapi/v1.0/glip/chats/#{chat_id}/posts",
                   body,
                   headers
                 ),
               {:ok, json} <- Jason.decode(body) do
            {:ok, json}
          end
        end

        def run(_function,
                _config,
                _meta,
                _credentials, args) do
          Logger.error("Error running Glip: ${inspect(args)}")
          {:error, %{"message" => "Unexpected args", "args" => inspect(args)}}
        end
      end
      """
    },
    config: %{
      "authorization" =>
        "bXB1dllZc2xUZWVMT3d2dU5kVmZiUTpqeUttVXJZRFNzcTl5dVhua0xwWV9BRmRyWC1BRTBUWjZjYlFwRGROUndtZw==",
      "client_id" => "mpuvYYslTeeLOwvuNdVfbQ",
      "client_secret" => "jyKmUrYDSsq9yuXnkLpY_AFdrX-AE0TZ6cbQpDdNRwmg"
    },
    functions: [
      %{
        name: "create_post",
        arg_template: %{
          "chat_id" => "306692102",
          "text" => "{$.firstName}"
        }
      }
    ]
  })
