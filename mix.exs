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
    [
      mod: {Mailsnail, []},
      applications: [:logger, :toniq, :asn1, :email]
    ]
  end

  defp deps do
    [
      {:email, github: "kivra/email", tag: "0.1.3"},
      {:httpoison, "~> 0.7"},
      {:toniq, github: "lafka/toniq", branch: "lafka-inject-uri"},
      {:dbl, git: "ssh://git@phabricator.highlands.tiny-mesh.com/diffusion/DBL/dbl.git", branch: "dbl-mongodb"}
    ]
  end
end
