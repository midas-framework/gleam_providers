defmodule GleamProviders.MixProject do
  use Mix.Project

  def project do
    [
      app: :gleam_providers,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      erlc_paths: ["src", "gen"],
      compilers: [:gleam | Mix.compilers()],
      deps: deps(),
      escript: escript()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [      
      {:mix_gleam, "~> 0.1.0"},
      {:gleam_stdlib, "~> 0.13.0"}
    ]
  end
  def escript do
    [main_module: GleamProviders.CLI]
  end
end

