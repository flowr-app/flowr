import Config

config :esbuild,
  version: "0.12.15",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure Mix tasks and generators
config :flowr,
  ecto_repos: [Flowr.Repo],
  generators: [binary_id: true]

config :flowr,
  ecto_repos: [Flowr.Repo],
  generators: [context_app: :flowr]

# Configures the endpoint
config :flowr, FlowrWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BlWSpAXmygQ21Aa9XWw3pTTeDgv3ZMg7mMI5FFbHU+w4UFBErBwmmb0xpvzFttfD",
  render_errors: [view: FlowrWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: FlowrWeb.PubSub,
  live_view: [
    signing_salt: "Vl/Lu0THG2IEq6XZWEGHjLVNjjVQK9L7BHr8F9NdzzrU6ifiaL+JH65zG0+yN/g9"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix_bootstrap_form,
  translate_error_function: &FlowrWeb.ErrorHelpers.translate_error/1

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
