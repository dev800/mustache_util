defmodule MustacheUtil.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mustache_util,
      version: "0.0.2",
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end

  defp description do
    "Mustache for Elixir"
  end

  def package do
    [
      contributors: ["jui"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/dev800/mustache_util"}
    ]
  end
end
