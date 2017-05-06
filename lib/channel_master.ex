defmodule AblyNg.ChannelMaster do
  use GenServer
  require Logger

  def start_link(key) do
    GenServer.start_link(__MODULE__, key)
  end

  # GenServer behaviour callbacks
  ###############################

  def init(key) do
    [app_id, channel_name] = String.split(key, ":")
    Logger.metadata [app_id: app_id, channel_name: channel_name]
    Logger.debug "New ChannelMaster initialized: #{inspect self()}, app_id: #{app_id}, channel_name: #{channel_name}"
    {:ok, %{app_id: app_id, channel_name: channel_name}}
  end
end
