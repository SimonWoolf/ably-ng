defmodule AblyNg do
  use Application
  require Logger

  def start(_type, _args) do
    case AblyNg.Supervisor.start_link do
      {:ok, pid} ->
        :ok = :riak_core.register(vnode_module: AblyNg.Vnode)
        :ok = :riak_core_node_watcher.service_up(AblyNg.Service, self())
        Logger.debug("Start AblyNg supervisor")
        {:ok, pid}
      {:error, reason} ->
        Logger.error("Unable to start AblyNg supervisor: #{inspect reason}")
    end
  end

end
