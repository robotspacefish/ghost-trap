require 'app/entity.rb'

class Player < Entity
  attr_accessor :total_ghosts_held, :backpack_limit, :beam, :is_shooting, :ghosts_on_beam, :beam_power, :beam_cooldown, :speed
  MAX_BEAM_POWER = 200
  BEAM_COOLDOWN = 1

  def initialize
    w = 99
    h = 300
    super($WIDTH/2-w/2, 90, w, h, "sprites/player_stance_01_green.png", false)
    @total_ghosts_held = 0
    @backpack_limit = 10
    @beam = {x: ((self.x + self.w)/2).to_i, y: self.y+h, h: 300, w: 23}
    @is_shooting = false

    @ghosts_on_beam = []
    @beam_power = MAX_BEAM_POWER
    @beam_cooldown = 0
    @speed = 6
  end

  def calc(args)
    if self.can_shoot? && self.is_shooting
      self.shoot(args)
    else
      self.ghosts_on_beam.each do |g|
        self.space_in_pack? ?
          self.store_ghost_in_pack(g, args) : self.remove_ghost_from_beam(g)
      end
    end

    self.refill_beam if !self.is_shooting && self.beam_power != MAX_BEAM_POWER

  end

  def refill_beam
    self.beam_power += 1
  end

  def reset_beam_power
    self.beam_power = MAX_BEAM_POWER
  end

  def store_ghost_in_pack(g, args)
    self.total_ghosts_held += 1

    self.remove_ghost_from_beam(g)

    remove_ghost(args, g)
  end

  def space_in_pack?
    self.total_ghosts_held < self.backpack_limit
  end

  def remove_ghost_from_beam(g)
    index = self.ghosts_on_beam.find_index { |gh| gh.id == g.id }
    self.ghosts_on_beam.slice!(index)
  end


  def move_right
    self.flip = false
    self.x += self.speed if self.x + self.w < $WIDTH
  end

  def move_left
    self.flip = true
    self.x -= self.speed if self.x > 0
  end

  def add_ghost_to_beam(ghost)
    self.ghosts_on_beam << ghost
  end

  def dispose_of_ghosts(disposal)
    if self.is_colliding_with?(disposal)
      disposal.deposit_ghosts(self.total_ghosts_held)
      self.empty_pack
    end
  end

  def empty_pack
     self.total_ghosts_held = 0
  end

  def shoot(args)
    # center beam on player (stance 1)
    self.beam.x = self.flip ? self.x + 32 : self.x + 36

    # countdown beam power
    self.beam_power -= 1

    # placeholder beam
    beam_sprite = 'sprites/beam_electric.png'
    if args.state.tick_count % 5== 0
      # TODO beam sprite change
    end

    args.outputs.sprites << [ self.beam.x, self.beam.y, self.beam.w, self.beam.h, beam_sprite ]


  end

  def can_shoot?
    self.beam_power > 0
  end

  def render_ui(args)
    self.render_beam_power(args)


    # args.outputs.labels << [$WIDTH - 200, 40, "Ghosts in Pack: #{self.total_ghosts_held}", 255, 255, 255]
    # args.outputs.labels << [$WIDTH - 200, 60, "Ghosts on Beam: #{self.ghosts_on_beam.size}", 255, 255, 255]
  end

  def render_beam_power(args)
    length = 400
    height = 20
    x = $WIDTH/2 - length/2
    y = 10

    # beam length changes based on how much power is left in beam
    beam_length = 2 * self.beam_power

    args.outputs.labels << [x, y + height + 20, "BEAM POWER", 0, 0, 0]
    args.outputs.sprites << [x, y, beam_length, height, "sprites/beam_power.png"]
    args.outputs.borders << [x, y, length, height, 0, 0, 255]
  end

  def serialize
    { x: x, y: y, w: w, h: h, total_ghosts_held: total_ghosts_held, backpack_limit: backpack_limit, beam: beam, is_shooting: is_shooting, ghosts_on_beam: ghosts_on_beam }
  end

end