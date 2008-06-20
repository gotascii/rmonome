require 'mono_gateway'
require 'monolife'

class Multilife
  def initialize(monome_size=8, monome_count=7)
    @monome_size = monome_size
    @monome_count = monome_count
    @monolifes = Array.new 
    @gateway = MonoGateway.new
    @reaktor = ReaktorGateway.new
    
    for i in 0...@monome_count
      add
    end
  end

  def add(monolife=nil)
    monolife ||= Monolife.new(@monome_size, @gateway, @reaktor)
    @monolifes.push monolife
    @gateway.box = monolife.box
    @reaktor.destination = monolife.box

    @monolifes.each do |from|
      @monolifes.each do |to|
        from.box.button_at(@monolifes.index(to) + 1, 0).on_press do |btn|
          @gateway.box = to.box
          @reaktor.destination = to.box
          to.box.display
        end
      end
    end
  end
  def run
    OSCGateway.run_gateways @gateway, @reaktor
  end
end