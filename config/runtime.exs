import Config

unless config_env() in [:dev, :test] do
  config :flowr, FlowrWeb.Endpoint,
    http: [port: System.get_env("PORT")],
    url: [scheme: "https", host: System.get_env("HOST"), port: 443],
    secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")

  # Configure your database
  config :flowr, Flowr.Repo,
    url: System.get_env("DATABASE_URL"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    ssl: true
end
