defmodule AblyNg.Frontend.WsServer do
  require Logger

  def start_link() do
    port = Application.fetch_env!(:ably_ng, :ws_port)
    {:ok, cowboy_pid} = :cowboy.start_clear(
      :ws,
      100,
      [ # ranch options
        port: port,
        max_connections: 10000
      ],
      %{ # cowboy options
        env: %{dispatch: routes()},
        timeout: 17500
      }
    )

    Logger.info "Started cowboy on pid #{inspect cowboy_pid}, listening on port #{inspect port}."
    {:ok, cowboy_pid}
  end

  defp routes do
    :cowboy_router.compile([
      {:_, # Match all hostnames
        [
          {"/", AblyNg.Frontend.WsHandler, []},
        ]
      }])
  end
end

