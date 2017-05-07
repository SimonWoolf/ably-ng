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
    [
      applications: [:riak_core, :logger, :cowboy],
      mod: {AblyNg, []}
    ]
  end

  defp deps do
    [
      {:riak_core, "~> 3.0", hex: :riak_core_ng},
      {:cowboy, github: "ninenines/cowboy", tag: "2.0.0-pre.8"},
      {:poison, "~> 3.1"},
      # nb see https://github.com/project-fifo/riak_core/issues/20
      {:cuttlefish, github: "basho/cuttlefish", tag: "2.0.11", manager: :rebar3, override: true},
      {:lager, github: "basho/lager", tag: "3.2.4", manager: :rebar3, override: true},
      {:goldrush, github: "basho/goldrush", tag: "0.1.9", manager: :rebar3, override: true},

      # Test deps
      {:socket, "~> 0.3.11", only: :test},
    ]
  end
end
