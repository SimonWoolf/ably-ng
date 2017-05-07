defmodule AblyNg.Frontend.ConnectionMaster do
  use GenServer
  use AblyNg.Types.ProtocolMessage
  alias AblyNg.{ChannelClient, ChannelClientSupervisor, Frontend.WsHandler}
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def add_transport(connection) do
    with :ok <- GenServer.call(connection, {:add_transport, self()}) do
      Process.monitor(connection)
    end
  end

  def on_protocol_message(connection, protocol_message) do
    GenServer.cast(connection, {:on_protocol_message, protocol_message})
  end

  def send_protocol_message(connection, protocol_message) do
    GenServer.cast(connection, {:send_protocol_message, protocol_message})
  end

  # GenServer behaviour callbacks
  ###############################

  def init(state) do
    Logger.debug "New ConnectionMaster initialized: #{inspect self()}, app_id: #{state.app_id}"
    {:ok, %{app_id: state.app_id, transport: nil}}
  end

  # TODO: remove transports automatically via the monitor if they die, and have
  # transports close if connection dies
  def handle_call({:add_transport, transport_pid}, _from, state) do
    Process.monitor(transport_pid)
    {:reply, :ok, %{state | transport: transport_pid}}
  end

  # ATTACH
  def handle_cast({:on_protocol_message, %{channel: channel_name, action: @action_attach}}, state) do
    # Don't need to actually get the channel client; it will listen for the added subscriber
    ChannelClientSupervisor.add_subscriber(channel_key(state.app_id, channel_name))
    # TODO send detach if this fails
    {:noreply, state}
  end

  # MESSAGE
  def handle_cast({:on_protocol_message, %{channel: channel_name, action: @action_message, messages: messages}}, state) do
    key = channel_key(state.app_id, channel_name)
    with {:ok, client} = ChannelClientSupervisor.get_client(key) do
        ChannelClient.publish(client, messages)
    end
    {:noreply, state}
  end

  def handle_cast({:on_protocol_message, message}, state) do
    Logger.warn "ConnectionMaster: can't yet handle #{inspect message}"
    {:noreply, state}
  end

  def handle_cast({:send_protocol_message, protocol_message}, state) do
    WsHandler.send_message(state.transport, protocol_message)
    {:noreply, state}
  end

  # Helpers
  #########

  defp channel_key(app_id, channel_name), do: "#{app_id}:#{channel_name}"
end
