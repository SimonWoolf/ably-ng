defmodule AblyNg.Vnode do
  require Logger
  @behaviour :riak_core_vnode

  # Vnode behaviour callbacks
  ###########################

  def start_vnode(partition) do
    :riak_core_vnode_master.get_vnode_pid(partition, __MODULE__)
  end

  def init([partition]) do
    {:ok, %{partition: partition, masters: %{channel: %{}}}}
  end

  def handle_command(:ping, _sender, state = %{partition: partition}) do
    {:reply, {:pong, partition}, state}
  end

  def handle_command({:master, {type, key}}, _sender, state) do
    try do
      {master, state} =  case state.masters[type] do
        %{^key => master} ->
          {master, state}
        _ ->
          master = spawn_master(type, key)
          {master, put_in(state.masters[type][key], master)}
      end
      {:reply, {:ok, master}, state}
    rescue
      e -> {:reply, {:error, e}, state}
    end
  end

  def handoff_starting(_dest, state) do
    {true, state}
  end

  def handoff_cancelled(state) do
    {:ok, state}
  end

  def handoff_finished(_dest, state) do
    {:ok, state}
  end

  def handle_handoff_command(_fold_req, _sender, state) do
    {:noreply, state}
  end

  def is_empty(state) do
    {true, state}
  end

  def delete(state) do
    {:ok, state}
  end

  def handle_handoff_data(_bin_data, state) do
    {:reply, :ok, state}
  end

  def encode_handoff_item(_k, _v) do
  end

  def handle_coverage(_req, _key_spaces, _sender, state) do
    {:stop, :not_implemented, state}
  end

  def handle_exit(pid, reason, state) do
    {:noreply, state}
  end

  def terminate(reason, _state) do
    :ok
  end

  # Helpers
  #########

  defp spawn_master(:channel, key) do
      {:ok, pid} = AblyNg.ChannelMaster.start_link(key)
      pid
  end
end
