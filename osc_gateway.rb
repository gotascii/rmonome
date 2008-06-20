require 'OSC'

class OSCGateway
  attr_accessor :destination
  # I am looking for a better way to do this.  I have limited expirience
  # with threads in Ruby and threads in general.
  def self.run_gateways(*gateways)
    threads = []
    gateways.each do |gateway|
      threads << Thread.new(gateway) do |gateway|
        gateway.run
      end
    end
    threads.each do |thread| thread.join end
  end
  def initialize(host='127.0.0.1', client=8001, server=8002)
    @client = OSC::SimpleClient.new(host, client)
    @server = OSC::SimpleServer.new(server)
  end
  def send(mesg, destination)
    if @destination == destination
      simple_mesg = OSC::SimpleMessage.new(mesg)
      @client.send(simple_mesg)
    end
  end
  def run
    thread = Thread.new(@server) do |server|
      server.run
    end
    thread.join
  end
end