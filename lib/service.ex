defmodule AblyNg.Service do
  require Logger

  def get_master(type, key) do
    # Note that we pass in the type/key twice -- first so riak core can locate
    # the vnode handling that master, second to pass to that vnode
    run_on_vnode(type, key, {:master, {type, key}})
  end

  defp run_on_vnode(type, key, command) do
    # Hash the key to a ring position
    idx = :riak_core_util.chash_key({type, key})

    # get an active preference list (ordered list of vnodes responsible for
    # that key). Want only one vnode per channel etc, so require length 1.
    # Last param: restrict to nodes that implement this service
    [{index_node, _inst}] = :riak_core_apl.get_primary_apl(idx, 1, AblyNg.Service)

    # riak core appends "_master" to the vnode name.
    # TODO sync_spawn_command, sync_command, or command
    :riak_core_vnode_master.sync_spawn_command(index_node, command, AblyNg.Vnode_master)
  end

  def show_ring do
    {:ok, ring} = :riak_core_ring_manager.get_my_ring
    :riak_core_ring.pretty_print(ring, [:legend])
  end
end
