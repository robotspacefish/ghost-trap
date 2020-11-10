require 'app/entity.rb'

class Player < Entity
  attr_accessor :total_ghosts_held, :ghost_limit, :beam, :is_shooting, :ghosts_on_beam
  SPEED = 4
  MAX_BEAM_POWER = 2

  def initialize
    w = 100
    super($WIDTH/2-w/2, 150, w, 80, "sprites/dragon-0.png", false)
    @total_ghosts_held = 0
    @ghost_limit = 10 # max amount of ghosts that can be stored in the backpack
    @beam = {x: (self.x + self.w/2).to_i, y: self.y+60, h: 300, w: 10}
    @is_shooting = false

    @ghosts_on_beam = []
    @beam_power = MAX_BEAM_POWER
  end

  def calc(args)
    if  self.is_shooting
      self.shoot(args)
    else
      if ghosts_on_beam.size > 0
        # store ghosts in pack up to limit
        # free any ghosts that don't fit
      end
    end
  end

  def remove_ghost_from_beam(g)
    index = self.ghosts_on_beam.find_index { |gh| gh.id == g.id }
    self.ghosts_on_beam.slice!(index)
  end

  def move_right
    self.flip = false
    self.x += SPEED if self.x + self.w < $WIDTH
  end

  def move_left
    self.flip = true
    self.x -= SPEED if self.x > 0
  end

  def add_ghost_to_beam(ghost)
    puts "ghost added: #{ghost}"
    self.ghosts_on_beam << ghost
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
    # args.outputs.labels << [$WIDTH - 200, 40, "Ghosts in Pack: #{self.total_ghosts_held}", 255, 255, 255]
    args.outputs.labels << [$WIDTH - 200, 60, "Ghosts on Beam: #{self.ghosts_on_beam.size}", 255, 255, 255]
  end

  def render_beam_power args
    # TODO
    # display beam power as a shrinking solid inside border, calc the shrinking by 10ths?
  end

  def serialize
    { x: x, y: y, w: w, h: h, total_ghosts_held: total_ghosts_held, ghost_limit: ghost_limit, beam: beam, is_shooting: is_shooting, ghosts_on_beam: ghosts_on_beam }
  end

end