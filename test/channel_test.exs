defmodule AblyNgTest.ChannelTest do
  use ExUnit.Case

  setup_all do
    port = Application.get_env(:ably_ng, :ws_port)
    {:ok, %{host: "localhost", port: port}}
  end

  test "Basic attach, send, receive", context do
    assert {:ok, ws} = Socket.Web.connect(context.host, context.port, path: "/")
    {:ok, attach} = Poison.encode(%{action: 10, channel: "test_channel"})
    assert :ok = Socket.Web.send(ws, {:text, attach})
    message = %{action: 15, channel: "test_channel", messages: ["foo", "bar"]}
    {:ok, encoded_message} = Poison.encode(message)
    assert :ok = Socket.Web.send(ws, {:text, encoded_message})
    assert {:ok, {:text, encoded_result}} = Socket.Web.recv(ws)
    {:ok, result} = Poison.decode(encoded_result, keys: :atoms)
    assert result == message
  end
end
