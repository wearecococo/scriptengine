defmodule Scriptengine.MixProject do
  use Mix.Project

  def project do
    [
      app: :scriptengine,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Scriptengine.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:lua, github: "wearecococo/lua", ref: "918fbaf5a30bef606286641c2dd7b1f145579029"},
      {:luerl, "~> 1.2.3"},
      {:uuid, "~> 1.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
