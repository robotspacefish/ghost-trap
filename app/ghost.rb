class Ghost < Entity
  attr_accessor :is_flickering, :is_invulnerable, :has_free_will, :is_in_beam, :id

  @@FLICKER_THRESHOLD = 255/2

  @@all = []

  def initialize(x, y)
    super(x, y, 80, 206, "sprites/ghost80.png", false)
    @is_flickering = true
    @is_invulnerable = true
    @alpha = 255 * 0.4
    @has_free_will = true
    @is_in_beam = false
    @id = set_id
  end

  def self.all
    @@all
  end

  def calc(tick_count)
    # use different sprite if ghost is on beam
    self.sprite_path = !self.is_in_beam ? "sprites/ghost80.png" : "sprites/ghost_on_beam.png"

    # keep in bounds
    self.y = $HEIGHT if self.y < 0 || self.y > $HEIGHT
    self.x = 0 if self.x < 0
    self.x = $WIDTH - self.w if self.x + self.w > $WIDTH

    self.toggle_flickering if tick_count % 60 == 0

    self.flicker if self.is_flickering

    self.move_freely(tick_count) if self.has_free_will
  end

  def collides_with_beam?(b)
    return false if !b
    self.rect.intersect_rect?([b.x, b.y, b.w, b.h])
  end


  def get_caught_in_beam
    self.is_in_beam = true
    self.has_free_will = false
  end

  def should_be_caught_by_beam?(b)
    # only catch if it is not already caught in beam
    !self.is_in_beam && self.collides_with_beam?(b) && !self.is_invulnerable
  end

  def release_from_beam
    self.has_free_will = true
    self.is_in_beam = false
  end

  def stick_to_beam(beam)
    # center ghost over beam
    diff = self.w - beam.w
    self.x = beam.x - diff/2
  end

  def move_freely(tick_count)
    self.has_free_will = true

    # keep above y=300
    self.y += self.y >= 300 ? -0.5 : 0.5

    self.wobble if tick_count % 10 == 0
  end

  def wobble
    self.x += rand <= 0.5 ? -10 : 10
    self.y += rand >= 0.5 ? -10 : 10
  end

  def flicker
    self.alpha = 255 * 0.4
  end

  def stop_flickering
    # play_sound(:flicker_in)
    self.is_flickering = false
    self.is_invulnerable = false
    self.alpha = 255
  end

  def toggle_flickering
    self.is_flickering ? self.stop_flickering : self.start_flickering
  end

  def start_flickering
    # play_sound(:flicker_out)
    if self.has_free_will
      self.is_flickering = true
      self.is_invulnerable = true
    end
  end

  def self.flicker_threshold
    @@FLICKER_THRESHOLD
  end

  def self.spawn
    x = random_int(20, $WIDTH - 100)
    y = random_int(400, $HEIGHT - 100)

    Ghost.new(x, y)
  end

  def serialize
    { x: x, y: y, w: w, h: h, is_flickering: is_flickering,  has_free_will: has_free_will, is_in_beam: is_in_beam, id: id}
  end
end

def random_int(min, max)
    rand(max - min) + min
end

def set_id
  "#{rand}#{rand}"
end