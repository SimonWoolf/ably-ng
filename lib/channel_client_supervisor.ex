defmodule AblyNg.ChannelClientSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    supervise([], strategy: :one_for_one)
  end

  def add_subscriber(channel_key) do
    with :ok <- ensure_client_exists(channel_key) do
      # Per-node attachment registry -- creating a registry (ie an ets table) per
      # channelclient would be too heavyweight. Could always just store a list of
      # pids in the channelclient state though?
      # connections should monitor and be monitored by the channelclient (which
      # should also add itself as a listener to the registry - or the
      # supervisor do that?), so channelclient can dispose of itself when no
      # longer needed
      {:ok, _} = Registry.register(AttachmentRegistry, channel_key, [])
      :ok
    end
  end

  def ensure_client_exists(channel_key) do
    # Effectively we use the supervisor's child list (and its behaviour of only
    # allowing one child with each id) as a registry. This is very convenient
    # and guarantees no race conditions, but is linear with number of channels
    # (as child list is a list), so if we start having hundreds of thousands of
    # channels per node, might want to change this to use the Registry to get
    # O(log(n)) behaviour
    case start_channel_client(channel_key) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, error} -> {:error, error}
    end
  end

  def start_channel_client(channel_key) do
    child_spec = worker(AblyNg.ChannelClient, [channel_key], id: channel_key)
    Supervisor.start_child(__MODULE__, child_spec)
  end
end

