defmodule Hydra.Mixfile do
  use Mix.Project

  def project do
    [app: :hydra,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     escript: escript]
  end

  def escript do
    [main_module: Hydra]
  end

  def application do
    [applications: [:cowboy, :logger, :plug, :httpoison]]
  end

  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"},
     {:httpoison, "~> 0.8.0"},
     {:poison, "~> 1.5"}]
  end
end
