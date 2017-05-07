defmodule AblyNg.ChannelClient do
  use GenServer
  require Logger
  alias AblyNg.{AttachmentRegistry, ChannelMaster, Service}

  def start_link(key) do
    GenServer.start_link(__MODULE__, key)
  end

  def add_subscriber(channel_key) do
    # Per-node attachment registry -- creating a registry (ie an ets table) per
    # channelclient would be too heavyweight. Could always just store a list of
    # pids in the channelclient state though?
    # TODO should connections link/monitor with the channelclient? need a
    # mechanism for channelclient to dispose of itself when no longer needed --
    # should it add itself as a listener to the registry (and monitor the
    # connections)?
    {:ok, _} = Registry.register(AttachmentRegistry, channel_key, [])
  end

  def on_message(channel_client, message) do
    GenServer.cast(channel_client, {:incoming, message})
  end

  def publish(channel_client, message) do
    GenServer.cast(channel_client, {:publish, message})
  end

  # GenServer behaviour callbacks
  ###############################

  def init(key) do
    {:ok, channel_master} = Service.get_master(:channel, key)
    ChannelMaster.add_client(channel_master)
    Logger.debug("New ChannelClient initialized: #{inspect self()}, key: #{key}")
    {:ok, %{key: key, channel_master: channel_master}}
  end

  def handle_cast({:incoming, message}, state) do
    Registry.dispatch(AttachmentRegistry, state.key, fn(attachments) ->
      for {connection, _} <- attachments do
        ConnectionMaster.send_channel_message(connection, message)
      end
    end)
  end

  def handle_cast({:publish, message}, _from, state) do
    ChannelMaster.on_message(state.channel_master, message)
  end
end
