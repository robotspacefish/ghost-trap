require 'app/entity.rb'

class Player < Entity
  attr_accessor :total_ghosts_held, :ghost_limit, :beam, :is_shooting
  SPEED = 4

  def initialize
    w = 100
    super($WIDTH/2-w/2, 150, w, 80, "sprites/dragon-0.png", false)
    @total_ghosts_held = 0
    @ghost_limit = 10 # max amount of ghosts that can be stored in the backpack
    @beam = {x: (self.x + self.w/2).to_i, y: self.y+60, h: 300, w: 10}
    @is_shooting = false
  end

  def calc(args)
    if self.is_shooting
      # self.beam.is_visible = true
      self.shoot(args)
    else
      # self.beam.is_visible = false
    end
  end

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

  def shoot(args)
    # self.beam.y += 3

    # center beam on player
    self.beam.x = self.x + self.w/2

    # placeholder beam
    args.outputs.sprites << [self.beam.x, self.beam.y, self.beam.w, self.beam.h, 'sprites/beam.png']


    # debug
    args.outputs.labels << [10, $HEIGHT - 20, "#{self.beam.x}, #{self.beam.y}", 255, 255, 255]
  end

  def render_ui args
    args.outputs.labels << [$WIDTH - 200, 40, "Ghosts in Pack: #{self.total_ghosts_held}", 255, 255, 255]
  end

end