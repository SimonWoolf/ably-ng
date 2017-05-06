defmodule AblyNg.ChannelMaster do
  use GenServer
  require Logger
  alias AblyNg.{ChannelClient}

  def start_link(key) do
    GenServer.start_link(__MODULE__, key)
  end

  def add_client(master) do
    with :ok <- GenServer.call(master, {:add_client, self(), Node.self()}) do
      Process.monitor(master)
    end
  end

  def on_message(channel_master, message) do
    GenServer.cast(channel_master, {:incoming, message})
  end

  # GenServer behaviour callbacks
  ###############################

  def init(key) do
    [app_id, channel_name] = String.split(key, ":")
    Logger.metadata [app_id: app_id, channel_name: channel_name]
    Logger.debug "New ChannelMaster initialized: #{inspect self()}, app_id: #{app_id}, channel_name: #{channel_name}"
    {:ok, %{key: key, app_id: app_id, channel_name: channel_name, clients: %{}}}
  end

  # TODO: remove clients automatically via the monitor if they die
  def handle_call({:add_client, client_pid, node_name}, _from, state = %{clients: clients}) do
    if Map.has_key?(clients, node_name) do
      Logger.warn("Channelmaster #{state.key} (#{inspect self}) -- client #{inspect client_pid} added for node #{node_name}, but there was already a client for that node: #{inspect clients[node_name]}. Replacing it")
    end
    Process.monitor(client_pid)
    state = put_in(state.clients[node_name], client_pid)
    {:reply, :ok, state}
  end

  def handle_cast({:incoming, message}, state) do
    for client <- state.clients do
      ChannelClient.on_message(client, message)
    end
  end
end
