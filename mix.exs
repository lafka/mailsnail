defmodule Mailsnail.Mixfile do
  use Mix.Project

  def project do
    [app: :mailsnail,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :toniq, :asn1, :email]]
  end

  defp deps do
    [
      {:email, github: "kivra/email", tag: "0.1.3"},
      {:httpoison, "~> 0.7"},
      {:toniq, "~> 1.0"}
    ]
  end
end