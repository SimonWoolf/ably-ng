defmodule AblyNg.Frontend.ConnectionMaster do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def add_transport(connection) do
    with :ok <- GenServer.call(connection, {:add_transport, self()}) do
      Process.monitor(connection)
    end
  end

  # GenServer behaviour callbacks
  ###############################

  def init(state) do
    Logger.debug "New ConnectionMaster initialized: #{inspect self()}, app_id: #{state.app_id}"
    {:ok, %{app_id: state.app_id, transports: MapSet.new}}
  end

  # TODO: remove transports automatically via the monitor if they die, and have
  # transports close if connection dies
  def handle_call({:add_transport, transport_pid}, _from, state = %{transports: transports}) do
    Process.monitor(transport_pid)
    transports = transports |> MapSet.put(transport_pid)
    {:reply, :ok, %{state | transports: transports}}
  end
end
