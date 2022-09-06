import Config

# Configure your database
config :flowr, Flowr.Repo,
  username: "postgres",
  password: "postgres",
  database: "flowr_test",
  hostname: System.get_env("DB_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :flowr, FlowrWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "fjkOJRyp5sz09GNzxkW7yKlPxVIKzu8LPhq9sb3Ftbg0tnmhcVfBn0Ijp+xswt1T",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
