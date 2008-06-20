require 'mono_gateway'

module Monome

  class Box
    attr_accessor :leds, :buttons
    attr_reader :size

    def initialize(size=8, gateway=nil)
      @gateway = gateway || MonoGateway.new(self)
      @size = size
      @leds = initialize_box_items(Led)
      @buttons = initialize_box_items(Button)
    end
    def led_at(x, y)
      @leds[x][y]
    end
    def button_at(x, y)
      @buttons[x][y]
    end
    def each_button(&block)
      each_box_item(@buttons, &block)
    end
    def each_led(&block)
      each_box_item(@leds, &block)
    end
    def turn_off_leds
      clear
      each_led do |led|
        led.turn_off
      end
    end
    def toggle_all
      each_button do |btn|
        btn.on_press do
          btn.led.toggle
        end
      end
    end
    def run
      @gateway.run
    end
    def clear
      @gateway.clear(self)
    end
    def display
      @gateway.display(self)
    end
    def display_led(led)
      @gateway.display_led(led, self)
    end
    protected
    def each_box_item(array)
      array.each do |row|
        row.each do |item|
          yield item
        end
      end
    end
    def initialize_box_items(klass)
      array = Array.new @size
      array.each_index do |x|
        array[x] = Array.new @size
        array[x].each_index do |y|
          array[x][y] = klass.new(x, y, self)
        end
      end
    end
  end
  class BoxItem
    attr_accessor :box, :x, :y
    def initialize(x, y, box)
      @x = x
      @y = y
      @box = box
    end
  end
  class Button < BoxItem
    attr_accessor :on_press, :on_release
    def initialize(*args)
      @pressed = false
      super(*args)
    end
    def on_press(&block)
      @on_press = block
    end
    def on_release(&block)
      @on_release = block
    end
    def pressed?
      @pressed
    end
    def press
      unless @on_press.nil?
        @on_press.call(self)
      end
      @pressed = true
    end
    def release
      unless @on_release.nil?
        @on_release.call(self)
      end
      @pressed = false
    end
    def led
      box.led_at(x, y)
    end
  end
  class Led < BoxItem
    def initialize(*args)
      @on = false
      super(*args)
    end
    def on?
      @on
    end
    def turn_on
      @on = true
      @box.display_led(self)
    end
    def turn_off
      @on = false
      @box.display_led(self)
    end
    def toggle
      if on?
        turn_off
      else
        turn_on
      end
    end
  end
end