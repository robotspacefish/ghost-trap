require 'app/entity.rb'

class Disposal < Entity
  attr_accessor :total_ghosts

  def initialize(y)
    super(50, y, 80, 80, 'sprites/hexagon-blue.png', false)
    @is_open = false
    @total_ghosts = 0
  end
end