defmodule AblyNg.Supervisor do
  use Supervisor

  def start_link do
    # riak_core appends _sup to the application name.
    Supervisor.start_link(__MODULE__, [], [name: :ably_ng_sup])
  end

  def init(_args) do
    children = [
      worker(:riak_core_vnode_master, [AblyNg.Vnode], id: AblyNg.Vnode_master_worker),
      worker(AblyNg.Frontend.WsServer, []),
      supervisor(Registry, [:duplicate, AblyNg.AttachmentRegistry, [partitions: System.schedulers_online()]], id: :attachment_registry),
      supervisor(AblyNg.Frontend.ConnectionSupervisor, []),
      supervisor(AblyNg.ChannelClientSupervisor, []),
    ]
    supervise(children, strategy: :one_for_one, max_restarts: 5, max_seconds: 10)
  end
end
