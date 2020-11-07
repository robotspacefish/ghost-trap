require 'app/entity.rb'

class Player < Entity
  attr_accessor :sprite

  SPEED = 3

  def initialize
    w = 100
    super($WIDTH/2-w/2, 150, w, 80)
    @sprite = "sprites/dragon-0.png"
  end

  def calc
  end

  def move_right
    # todo sprite direction
    self.x += SPEED if self.x + self.w < $WIDTH
  end

  def move_left
    # todo sprite direction
    self.x -= SPEED if self.x > 0
  end
end