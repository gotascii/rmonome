require 'reaktor_gateway'
require 'monome'

class Monolife
  attr_accessor :box, :cell_grid
  def initialize(size=8, mono_gateway=nil, reaktor=nil)
    initialize_world
    @reaktor = reaktor || ReaktorGateway.new
    @box = Monome::Box.new(size, mono_gateway)
    @reaktor.destination = @box
    @box.each_button do |btn|
      btn.on_press do
        if edit_pressed?
          btn.led.toggle
          @world[btn.x][btn.y][2] = 1 - @world[btn.x][btn.y][2]
        end
      end
    end
    @box.button_at(0, 0).on_press do
      sync_monome_with_editable
    end
    @box.button_at(0, 0).on_release do
      sync_monome_with_active
    end
    @reaktor.on_tick do |reset|
      if reset == 1
        @box.turn_off_leds unless edit_pressed?
        sync_editable_with_active
      end
      evolve
    end
  end
  def edit_pressed?
    @box.button_at(0, 0).pressed?
  end
  def evolve
    # evolve the active grid
    encodings = []
    for x in 0...8
      binary = ''
      for y in 0...8
        if @world[x][y][1] == 1
          @world[x][y][0] = 1
          binary += '1'
          @box.led_at(x, y).turn_on unless edit_pressed?
        elsif @world[x][y][1] == -1
          @world[x][y][0] = 0
          binary += '0'
          @box.led_at(x, y).turn_off unless edit_pressed?
        else
          binary += '0'
        end
        @world[x][y][1] = 0
      end
      encodings << binary.to_i(2)
    end
    @reaktor.send('/monolife ' + encodings.join(" "), @box)

    # determine next evolution
    for x in 0...8
      for y in 0...8
        count = neighbors(x, y)
        @world[x][y][1] = 1 if count == 3 && @world[x][y][0] == 0
        @world[x][y][1] = -1 if ((count < 2 || count > 3) && @world[x][y][0] == 1)
      end
    end
  end
  def neighbors(x, y)
    @world[(x + 1) % 8][y][0] + 
    @world[x][(y + 1) % 8][0] + 
    @world[(x + 8 - 1) % 8][y][0] + 
    @world[x][(y + 8 - 1) % 8][0] + 
    @world[(x + 1) % 8][(y + 1) % 8][0] + 
    @world[(x + 8 - 1) % 8][(y + 1) % 8][0] + 
    @world[(x + 8 - 1) % 8][(y + 8 - 1) % 8][0] + 
    @world[(x + 1) % 8][(y + 8 - 1) % 8][0]
  end
  def sync_monome_with_editable
    @box.turn_off_leds
    for x in 0...8
      for y in 0...8
        @box.led_at(x, y).turn_on if @world[x][y][2] == 1
      end
    end
  end
  def sync_monome_with_active
    @box.turn_off_leds
    for x in 0...8
      for y in 0...8
        @box.led_at(x, y).turn_on if @world[x][y][0] == 1
      end
    end
  end
  def sync_editable_with_active
    for x in 0...8
      for y in 0...8
        @world[x][y][0] = 0
        @world[x][y][1] = @world[x][y][2]
      end
    end
  end
  def each_cel
    yield item
  end
  def initialize_world
    @world = []
    for x in 0...8
      @world[x] = []
      for y in 0...8
        @world[x][y] = []
        @world[x][y][0] = 0
        @world[x][y][1] = 0
        @world[x][y][2] = 0
      end
    end
  end
  def run
     OSCGateway.run_gateways @box, @reaktor
  end
end