defmodule AblyNg.Frontend.WsHandler do
  require Logger
  use AblyNg.Types.ProtocolMessage
  alias AblyNg.Frontend.{ConnectionSupervisor, ConnectionMaster}

  def init(req, _opts) do
    Logger.debug "cowboy websocket handler init #{inspect self()}: new req #{inspect req}"
    {:cowboy_websocket, req, %{app_id: "fake_appid"}}
  end

  def websocket_init(state) do
    {:ok, connection} = find_connection(state)
    ConnectionMaster.add_transport(connection)
    {:ok, Map.put(state, :connection, connection)}
  end

  def websocket_handle({:text, message}, state) do
    Logger.debug "Cowboy ws handler #{inspect self()}: received message from client with content #{message}"
    case Poison.decode(message, as: %ProtocolMessage{}) do
      {:ok, protocol_message} ->
        ConnectionMaster.on_protocol_message(state.connection, protocol_message)
      {:error, error} ->
        Logger.warn "Unable to decode protocol message #{message}: #{inspect error}"
    end
    {:ok, state}
  end

  def websocket_info(message, state) do
    Logger.debug "Cowboy ws handler #{inspect self()}: Received message #{inspect message}"
    {:reply, {:text, "HIII"}, state}
  end

  defp find_connection(state) do
    if state[:connection_id] do
      # TODO implement using cross-mesh connectionid registry - syn?
      nil
    else
      ConnectionSupervisor.start_connection_master(%{app_id: state.app_id})
    end
  end
end
