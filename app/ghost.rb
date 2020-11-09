require 'app/entity.rb'

class Ghost < Entity
  def initialize(x, y)
    super(x, y, 80, 80, "sprites/circle-white.png", false)
    puts "initiating ghost at #{x}, #{y}"
  end
end