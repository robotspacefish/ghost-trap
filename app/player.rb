require 'app/entity.rb'

class Player < Entity
  attr_accessor :sprite

  SPEED = 3

  def initialize
    super(50, 100, 100, 80)
    @sprite = "sprites/dragon-0.png"
  end

  def calc
  end

  def move_right
    # todo sprite direction
    self.x += SPEED
  end

  def move_left
    # todo sprite direction
    self.x -= SPEED
  end
end