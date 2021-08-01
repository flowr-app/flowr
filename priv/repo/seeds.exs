# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Flowr.Repo.insert!(%Flowr.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# bootstrap_sql = File.read!("priv/repo/flowr_dev_may_6_2019.dump")

# Ecto.Adapters.SQL.query!(Flowr.Repo, bootstrap_sql)

alias Flowr.Repo

{:ok, dropbox_connector} =
  Flowr.Exterior.create_connector(%{
    name: "Dropbox (Example)",
    description: "Example: Dropbox",
    auth: %{
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
    },
    run_info: %{
      adapter: "local",
      source_code: ~S"""
      defmodule Flowr.Connector.Dropbox do
        require Logger

        @behaviour Flowr.Exterior.Connector.Behaviour

        @functions ~w(upload_file)

        @impl true
        def functions() do
          @functions
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
      """
    },
    config: %{
      app_key: "t5oq0r5iz1i4ppw",
      app_secret: "z639aysjubhgc4x"
    },
    functions: [
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
  })

{:ok, customer} =
  Flowr.Accounts.create_customer_from_oauth_token(%{
    "access_token" =>
      "U0pDMTFQMDFQQVMwMHxBQUJhd1lSYlVYaXBuQTRYUHpVcXo1RXk2WEUxUFNyX1ZwakNLWDY5dGFPM3dUczczLWhBVHlNRzBsQjFCeFZjeDVCNF9QWWRPMEVYNENYQjd4dmJsWHJoanNBeWJqTHNTaEE4RWFEc3FFZ0lVR01aNjdqbjFkVWZsSnpWZ01zOU82VHQ0LUdCMUY3SFRXTjZ6RTRkWktfN21nZjdfM3pUNXVMR01BTEhnMXR2eFo4YW94TmhLX0JjUkpnSjJ0eUJmWGJEMGl4ZmJwejRxd0VvU3VPOGJHV0p8WTJycnJBfEgzWWp1dDFVWHMxNjNaYm40N2NHX2d8QUE",
    "endpoint_id" => "NdRqMTt9SNOpd5aYBZCq1g",
    "expires_in" => 3600,
    "owner_id" => "245715004",
    "refresh_token" =>
      "U0pDMTFQMDFQQVMwMHxBQUJhd1lSYlVYaXBuQTRYUHpVcXo1RXk2WEUxUFNyX1ZwakNLWDY5dGFPM3dUczczLWhBVHlNRzBsQjFCeFZjeDVCNF9QWWRPMEVYNENYQjd4dmJsWHJocmIyTi1XRm1EZmM4RWFEc3FFZ0lVTlR5RE1NeDY0bndsSnpWZ01zOU82VHQ0LUdCMUY3SFRXTjZ6RTRkWktfN21nZjdfM3pUNXVMR01BTEhnMXR2eFo4YW94TmhLX0JjUkpnSjJ0eUJmWFlxQXlFUm5ENEtRdU8wSnhQbU5zZEp8WTJycnJBfGU1QWJ5WGNlTlZJNWs0cjdDVVFES2d8QUE",
    "refresh_token_expires_in" => 604_800,
    "scope" =>
      "ReadMessages Faxes ReadPresence Meetings VoipCalling ReadCallRecording Glip ReadContacts Contacts ReadAccounts EditExtensions RingOut SMS InternalMessages ReadCallLog SubscriptionWebhook EditMessages EditPresence",
    "token_type" => "bearer"
  })

{:ok, trigger} =
  Flowr.Platform.create_trigger(customer.id, %{
    "name" => "Contacts",
    "category" => "polling",
    "polling" => %{
      "endpoint" => "/account/~/extension/~/address-book/contact"
    }
  })

{:ok, trigger} =
  Flowr.Platform.create_trigger(customer.id, %{
    "name" => "Call logs",
    "category" => "polling",
    "polling" => %{
      "endpoint" => "/account/~/extension/~/call-log"
    }
  })

{:ok, voicemail_trigger} =
  Flowr.Platform.create_trigger(customer.id, %{
    "name" => "New VoiceMail",
    "category" => "subscription",
    "subscription" => %{
      "event_type" => "/restapi/v1.0/account/~/extension/~/voicemail"
    }
  })

{:ok, trigger} =
  Flowr.Platform.create_trigger(customer.id, %{
    "name" => "New SMS",
    "category" => "subscription",
    "subscription" => %{
      "event_type" => "/restapi/v1.0/account/~/extension/~/message-store/instant?type=SMS"
    }
  })

{:ok, dropbox_account} =
  Flowr.Exterior.create_account(customer, %{
    name: "Jun's Dropbox",
    connector_id: dropbox_connector.id
  })

{:ok, dropbox_account} =
  Flowr.Exterior.update_account(dropbox_account, %{
    credentials: %{
      "access_token" => "Vuw1JHA35XQAAAAAAADKgWNCkFiYLXNksakVWwAGaP9qFOl0yJqp8wkhgLnhv1ig",
      "account_id" => "dbid:AACEZIP5HL-GBJJxsw18o269lqYE63D3Lw4",
      "token_type" => "bearer",
      "uid" => "337233"
    }
  })

{:ok, flow} =
  Flowr.Automation.create_flow(customer, %{
    "actions" => %{
      "0" => %{
        "account_id" => dropbox_account.id,
        "args_template" =>
          "{\n  \"file\": {\n    \"path\": \"/Demo/{$.body.from.name}.txt\",\n    \"content\": \"{$.body.attachments[0].uri}\"\n  }\n}",
        "connector_id" => dropbox_connector.id,
        "function" => "upload_file",
        "id" => "450518f2-ba30-437d-90a3-da234a0eb1f4"
      }
    },
    "name" => "Save VoiceMail to Dropbox",
    "trigger_id" => voicemail_trigger.id
  })
