defmodule Haphazard.Mixfile do
  use Mix.Project

  def project do
    [app: :haphazard,
     version: "0.3.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
   ]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Haphazard.Application, []}]
  end

  defp deps do
    [
      {:plug, "~> 1.3"},
      {:credo, "~> 0.6.1", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:excoveralls, "~> 0.6", only: :test},
    ]
  end

  defp description do
    """
    A configurable plug for caching.
    """
  end

  defp package do
    [
     name: :haphazard,
     files: ["config", "lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Rodrigo Nonose"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/digitalnatives/haphazard"}
    ]
  end

end
