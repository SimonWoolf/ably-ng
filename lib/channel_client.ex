defmodule AblyNg.ChannelClient do
  use GenServer
  require Logger
  use AblyNg.Types.ProtocolMessage
  alias AblyNg.{AttachmentRegistry, ChannelMaster, Service, Frontend.ConnectionMaster}

  def start_link(key) do
    GenServer.start_link(__MODULE__, key)
  end

  def on_message(channel_client, messages) do
    GenServer.cast(channel_client, {:incoming, messages})
  end

  def publish(channel_client, messages) do
    GenServer.cast(channel_client, {:publish, messages})
  end

  # GenServer behaviour callbacks
  ###############################

  def init(key) do
    [app_id, channel_name] = String.split(key, ":")
    {:ok, channel_master} = Service.get_master(:channel, key)
    ChannelMaster.add_client(channel_master)
    Logger.debug("New ChannelClient initialized: #{inspect self()}, key: #{key}")
    {:ok, %{key: key, channel_master: channel_master, channel_name: channel_name, app_id: app_id}}
  end

  def handle_cast({:incoming, messages}, state) do
    protocol_message = %ProtocolMessage{
      action: @action_message,
      channel: state.channel_name,
      messages: messages
    }
    Registry.dispatch(AttachmentRegistry, state.key, fn(attachments) ->
      for {connection, _} <- attachments do
        ConnectionMaster.send_protocol_message(connection, protocol_message)
      end
    end)
    {:noreply, state}
  end

  def handle_cast({:publish, message}, state) do
    ChannelMaster.on_message(state.channel_master, message)
    {:noreply, state}
  end
end
