defmodule Haphazard.Mixfile do
  use Mix.Project

  def project do
    [app: :haphazard,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Haphazard.Application, []}]
  end

  defp deps do
    [
      {:plug, "~> 1.3"},
      {:credo, "~> 0.6.1", only: [:dev, :test]},
    ]
  end
end
