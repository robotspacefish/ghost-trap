require 'app/entity.rb'

class Ghost < Entity
  attr_accessor :sprite

  def initialize(x, y)
    super(x, y, 80, 80)
    @sprite = "sprites/circle-white.png"
    puts "initiating ghost at #{x}, #{y}"
  end
end