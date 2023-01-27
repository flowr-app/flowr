defmodule Flowr.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      app: :flowr,
      version: "0.1.0",
      build_path: "_build",
      config_path: "config/config.exs",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Flowr, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.6"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.1", override: true},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.1"},
      {:esbuild, "~> 0.3", runtime: Mix.env() == :dev},

      # phx extra
      {:phoenix_active_link, "~> 0.3.0"},
      {:phoenix_live_view, "~> 0.18"},
      {:phoenix_live_dashboard, "~> 0.7"},
      {:phoenix_bootstrap_form, "~> 0.1.0"},

      # extra
      {:ringcentral, "~> 0.2", github: "ringcentral-elixir/ringcentral_elixir"},
      {:finch, "~> 0.9"},
      {:flow, "~> 1.2.0"},
      {:broadway, "~> 1.0"},
      {:broadway_dashboard, "~> 0.3.0"},
      {:execjs, "~> 2.0"},
      {:jaxon, "~> 2.0"},
      {:json_xema, "~> 0.1"},
      {:ecto_psql_extras, "~> 0.2"},
      {:httpoison, "~> 2.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
