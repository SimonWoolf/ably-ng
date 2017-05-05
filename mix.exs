defmodule AblyNg.Mixfile do
  use Mix.Project

  def project do
    [app: :ably_ng,
     version: "0.0.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:riak_core, "~> 3.0", hex: :riak_core_ng},
      {:cowboy, github: "ninenines/cowboy", tag: "2.0.0-pre.8"},
      {:poison, "~> 3.1"},
    ]
  end
end
