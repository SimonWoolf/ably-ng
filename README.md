# ably-ng

Experimental reimplementation of Ably in Elixir. Just for fun -- this isn't likely to replace current realtime any time soon.

### Design

Takes a lot of inspiration from current realtime, but leans heavily on existing, battle-hardened Erlang and Riak Core functionality wherever possible.

Instead of grpc and axon sockets, it uses Erlang distribution: all nodes in a region are connected in an Erlang mesh. This means that it no longer makes sense to have separate cores and frontends -- since all nodes are connected to all other nodes, a bipartite topology no longer gains us anything, since we effectively already have the complete graph on n nodes. So we only have one node type.

It's built on top of [Riak Core](https://github.com/basho/riak_core/wiki), which gives us battle-tested implementations of the ring, gossip, ownership handoff with ring changes, configurable redundancy, and so on.

It retains the basic channelmaster/client design, using one channelclient per node. ChannelMasters only communicate with channelClients. Connections subscribe to channelclients using (local) process groups, and the channelclient broadcasts to the group.

Instead of refcounting and garbage collection, we lean on erlang process monitoring, so that we're notified if a monitored process dies no matter how that happened (even if the whole node the process was on dies unexpectedly) - again, leaning on existing functionality.

### Problems

There are two big disadvantages to the mesh design compared with the current design. The first is that it doesn't scale to more than a hundred or so nodes. This is ameliorated by the fact that each node can make full use of multicore machines, scaling linearly with cores -- a hundred m4.16xlarge's would go a long way. (There are also plans to optionally use [Kademlia routing](https://en.wikipedia.org/wiki/Kademlia) in Erlang 20 or 21, which will allow vastly larger meshes).

The other big disadvantage is that Erlang meshes that span multiple regions don't work well: the design assumes low latency between nodes. So for multiple regions, we'd have one erlang mesh per region, with regions subscribing to each other and a globalmaster mechanism, as we do now, or per https://github.com/ably/wiki/issues/189. Would need to put thought into how that would work -- seems a shame to get rid of grpc/axon within a region if we have to introduce something similar for inter-region.
