defmodule Logic.MixProject do
  use Mix.Project

  def project do
    [
      app: :logic,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application, do: [extra_applications: [:logger]]
  defp deps, do: [{:nimble_parsec, "~> 1.2"}]
end
