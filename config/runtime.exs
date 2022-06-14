import Config

if System.get_env("PHX_SERVER") do
  config :flowr, FlowrWeb.Endpoint, server: true
end

unless config_env() in [:dev, :test] do
  host = System.get_env("PHX_HOST") || "example.com"

  config :flowr, FlowrWeb.Endpoint,
    http: [port: System.get_env("PORT")],
    url: [scheme: "https", host: host, port: 443],
    secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")

  # Configure your database
  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :flowr, Flowr.Repo,
    url: System.get_env("DATABASE_URL"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    ssl: true,
    socket_options: maybe_ipv6
end
