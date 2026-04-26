defmodule CanAssociate.MixProject do
  use Mix.Project

  def project do
    [
      app: :can_associate,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {CanAssociate.Application, []}
    ]
  end
end
