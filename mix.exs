defmodule WipoSt3.MixProject do
  use Mix.Project

  @version "1.0.0"
  @repo_url "https://github.com/schwarz/wipo_st3"
  def project do
    [
      app: :wipo_st3,
      version: @version,
      elixir: "~> 1.20",
      deps: deps(),

      # Hex
      description: "WIPO ST.3 Country Codes and English Names",
      package: package(),

      # Docs
      docs: &docs/0
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp package do
    [
      licenses: [],
      links: %{
        "GitHub" => @repo_url
      }
    ]
  end

  defp docs do
    [
      main: WipoSt3,
      source_url: @repo_url
    ]
  end
end
