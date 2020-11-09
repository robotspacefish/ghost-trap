require 'app/entity.rb'

class Player < Entity
  SPEED = 4

  def initialize
    w = 100
    super($WIDTH/2-w/2, 150, w, 80, "sprites/dragon-0.png", false)
  end

  def calc

  end

  def move_right
    # todo sprite direction
    self.flip = false
    self.x += SPEED if self.x + self.w < $WIDTH
  end

  def move_left
    # todo sprite direction
    self.flip = true
    self.x -= SPEED if self.x > 0
  end

  def draw
    [x, y, w, h, sprite_path, 0, 255, 255, 255, 0, 0, 0, -1, -1, self.flip, false,  0.5, 1.0]
  end

end