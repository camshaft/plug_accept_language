defmodule PlugAcceptLanguage.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_accept_language,
     description: "parse the accept-language header",
     version: "0.1.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{ :plug, ">= 1.0.0" },
     { :excheck, "~> 0.5.3", only: [:dev, :test] },
     { :triq, github: "triqng/triq", only: [:dev, :test] },]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*"],
     maintainers: ["Cameron Bytheway"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/camshaft/plug_accept_language"}]
  end
end
