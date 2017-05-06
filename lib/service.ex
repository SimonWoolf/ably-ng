defmodule AblyNg.Service do
  require Logger

  # Useful explanations: https://medium.com/@naveennegi/riak-core-with-elixir-part-four-f9c12e2bda19
  def ping(key) when is_binary(key) do
    # Hash the channel name to a ring position
    idx = :riak_core_util.chash_key({:channel, key})

    # get an active preference list (ordered list of vnodes responsible for
    # that channel). Want only one vnode per channel, so require length 1.
    # Last param: restrict to nodes that imlement the channelservice
    [{index_node, inst}] = :riak_core_apl.get_primary_apl(idx, 1, AblyNg.Service)
    Logger.debug "channel ping; Index node: #{inspect index_node}; inst #{inspect inst}"

    # riak core appends "_master" to the vnode name.
    # TODO sync_spawn_command, sync_command, or command
    :riak_core_vnode_master.sync_spawn_command(index_node, :ping, AblyNg.Vnode_master)
  end

  def show_ring do
    {:ok, ring} = :riak_core_ring_manager.get_my_ring
    :riak_core_ring.pretty_print(ring, [:legend])
  end
end
