require 'osc_gateway'

class ReaktorGateway < OSCGateway
  def on_tick(&block)
    @server.add_method('/clock', nil) do |mesg|
      reset = mesg.to_a[0]
      block.call(reset)
    end
  end
end