class Player < Entity
  attr_accessor :total_ghosts_held, :backpack_limit, :beam, :is_shooting, :ghosts_on_beam, :beam_power, :beam_cooldown, :speed, :is_walking, :sprite_frame
  MAX_BEAM_POWER = 200
  BEAM_COOLDOWN = 1

  def initialize
    w = 114
    h = 300
    super($WIDTH/2-w/2, 90, w, h, "sprites/player_green_1.png", false)
    @total_ghosts_held = 0 # total ghosts in pack
    @backpack_limit = 10
    @beam = {x: ((self.x + self.w)/2).to_i, y: self.y+h, h: 300, w: 23}
    @is_shooting = false

    @ghosts_on_beam = []
    @beam_power = MAX_BEAM_POWER
    @beam_cooldown = 0
    @speed = 6
    @is_walking = false
    @sprite_frame = 0

  end

  def set_sprite
    status_color = self.space_in_pack? ? "green" : "red"
    self.sprite_path = "sprites/player_#{status_color}_#{self.sprite_frame+1}.png"
  end

  def total_ghosts_on_beam
    self.ghosts_on_beam.size
  end

  def has_ghosts_on_beam?
    self.total_ghosts_on_beam > 0
  end

  def store_ghosts_from_beam_to_pack(args)
    self.ghosts_on_beam.each { |g| self.store_ghost_in_pack(g, args) }
  end

  def can_fit_all_beam_ghosts_in_pack?
    self.total_ghosts_held + self.ghosts_on_beam.size < self.backpack_limit
  end

  def add_ghost_to_beam(ghost)
    self.ghosts_on_beam << ghost
  end

  def store_ghost_in_pack(g, args)
    self.total_ghosts_held += 1

    remove_ghost(args, g)
  end

  def space_in_pack?
    self.total_ghosts_held < self.backpack_limit
  end

  def remove_ghost_from_beam(g)
    index = self.ghosts_on_beam.find_index { |gh| gh.id == g.id }
    self.ghosts_on_beam.slice!(index)
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

  def calc(args)
    self.sprite_frame = self.is_walking ? args.state.tick_count.idiv(6).mod(2) : 0

    if self.can_shoot? && self.is_shooting

      self.shoot(args)

    elsif self.has_ghosts_on_beam?

      add_score(args, self.total_ghosts_on_beam)

      self.store_ghosts_from_beam_to_pack(args)

      self.ghosts_on_beam.clear


    end

    self.refill_beam if !self.is_shooting && self.beam_power != MAX_BEAM_POWER

  end

  def refill_beam
    self.beam_power += 1
  end

  def reset_beam_power
    self.beam_power = MAX_BEAM_POWER
  end

  def move_right
    self.is_walking = true
    self.flip = false
    self.x += self.speed if self.x + self.w < $WIDTH
  end

  def move_left
    self.is_walking = true
    self.flip = true
    self.x -= self.speed if self.x > 0
  end

  def stop_moving
    self.is_walking = false
  end

  def shoot(args)
    # center beam on player (stance 1)
    self.beam.x = self.flip ? self.x + 40 : self.x + 44

    # countdown beam power
    self.beam_power -= 1

    beam_sprite = 'sprites/beam_electric.png'
    if args.state.tick_count % 5== 0
      # TODO beam sprite change
    end

    args.outputs.sprites << [ self.beam.x, self.beam.y, self.beam.w, self.beam.h, beam_sprite ]
  end

  def can_shoot?
    self.beam_power > 0 && self.can_fit_all_beam_ghosts_in_pack?
  end

  def render
    self.set_sprite

    super
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