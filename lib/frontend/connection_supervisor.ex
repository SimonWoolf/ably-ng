defmodule AblyNg.Frontend.ConnectionSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    children = [
      worker(AblyNg.Frontend.ConnectionMaster, [], restart: :transient),
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def start_connection_master(opts) do
    Supervisor.start_child(__MODULE__, [opts])
  end
end
