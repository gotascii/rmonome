require 'osc_gateway'

class MonoGateway < OSCGateway
  def initialize(box=nil, host='127.0.0.1', client=8080, server=8000)
    alias box= destination=
    alias box destination

    super(host, client, server)
    @destination = box

    # handle button presses
    @server.add_method('/box/press', nil) do |mesg|
      x, y, state = mesg.to_a[0..2]
      button = self.box.button_at(x, y)
      if state == 1
        button.press
      elsif state == 0
        button.release
      end
    end
  end
  def display!(box)
    @destination = box
    display(@destination)
  end
  #
  def display(box)
    @destination.each_led do |led|
      display_led(led, box)
    end
  end
  #
  def clear(box)
    for x in 0..@destination.size
      send("/led_row #{x}  0", box)
    end
  end
  #
  def display_led(led, box)
    send("/led #{led.x} #{led.y} 1", box) if led.on?
    send("/led #{led.x} #{led.y} 0", box) unless led.on?
  end
  def send(mesg, box)
    #simple_mesg = OSC::SimpleMessage.new('/box' + mesg)
    #@client.send(simple_mesg)
    super '/box' + mesg, box
    #puts self.
  end
end