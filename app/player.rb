require 'app/entity.rb'

class Player < Entity
  attr_accessor :total_ghosts_held, :ghost_limit
  SPEED = 4

  def initialize
    w = 100
    super($WIDTH/2-w/2, 150, w, 80, "sprites/dragon-0.png", false)
    @total_ghosts_held = 0
    @ghost_limit = 10 # max amount of ghosts that can be stored in the backpack
  end

  # def calc

  # end

  def move_right
    self.flip = false
    self.x += SPEED if self.x + self.w < $WIDTH
  end

  def move_left
    self.flip = true
    self.x -= SPEED if self.x > 0
  end

  def store_ghost_in_pack
    self.total_ghosts_held += 1 if self.total_ghosts_held < self.ghost_limit
  end

  # def draw
  #   [
  #     x, y, w, h, sprite_path,
  #     0,              # ANGLE
  #     255,            # ALPHA
  #     255,            # RED SATURATION
  #     255,            # GREEN SATURATION
  #     255,            # BLUE SATURATION
  #     0,              # TILE X
  #     0,              # TILE Y
  #     self.w,         # TILE W
  #     self.h,         # TILE H
  #     self.flip,      # FLIP HORIZONTALLY
  #     false           # FLIP VERTICALLY
  #   ]
  # end


  def render_ui args
    args.outputs.labels << [$WIDTH - 200, 40, "Ghosts in Pack: #{self.total_ghosts_held}", 255, 255, 255]
  end

end