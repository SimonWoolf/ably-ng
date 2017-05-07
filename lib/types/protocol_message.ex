defmodule AblyNg.Types.ProtocolMessage do
  defstruct action: nil, channel: nil, messages: nil
  @type t :: %AblyNg.Types.ProtocolMessage{
    action: non_neg_integer,
    channel: String.t,
    messages: [String.t] # temp, will be Message.t once Message type is implemented
  }

  def actions do
    [
      heartbeat:     0,
      ack:           1,
      nack:          2,
      connect:       3,
      connected:     4,
      disconnect:    5,
      disconnected:  6,
      close:         7,
      closed:        8,
      error:         9,
      attach:        10,
      attached:      11,
      detach:        12,
      detached:      13,
      presence:      14,
      message:       15,
      sync:          16
    ]
  end

  defmacro __using__(_opts) do
    quote do
      alias AblyNg.Types.ProtocolMessage
      Enum.each(ProtocolMessage.actions, fn({name, code}) ->
        attrname = String.to_atom("action_" <> Atom.to_string(name))
        Module.put_attribute(__MODULE__, attrname, code)
      end)
    end
  end
end
