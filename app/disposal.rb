require 'app/entity.rb'

class Disposal < Entity
  attr_accessor :total_ghosts, :is_open

  def initialize(y)
    super(50, y, 80, 80, 'sprites/hexagon-blue.png', false)
    @is_open = false
    @total_ghosts = 0
  end

  def deposit_ghosts(total_to_add)
    self.total_ghosts += total_to_add
  end

  def calc(player)
    self.is_open = self.is_colliding_with?(player)
  end

  def render
    self.sprite_path = self.is_open ? 'sprites/hexagon-orange.png' : 'sprites/hexagon-blue.png'

    super
  end
end

# method to change is_open to true/false when colliding with player