require 'app/entity.rb'

class Ghost < Entity
  attr_accessor :is_flickering, :is_invulnerable, :has_free_will, :is_in_beam, :id, :has_been_in_beam # <- debug

  @@FLICKER_THRESHOLD = 255/2
  @@ID = 1

  @@all = []

  def initialize(x, y)
    # puts "initiating ghost at #{x}, #{y}"
    super(x, y, 80, 80, "sprites/circle-white.png", false)
    @is_flickering = false
    @is_invulnerable = false
    @has_free_will = true
    @is_in_beam = false
    @id = @@ID

    @@ID += 1

    @has_been_in_beam = false # for debug
  end

  def self.all
    @@all
  end


  def should_be_caught_by_beam?
    self.is_in_beam = true if !self.is_in_beam && !self.has_free_will && !self.is_invulnerable

    self.is_in_beam
  end

  def should_be_released_from_beam?
    self.is_in_beam = false if self.has_free_will && self.is_in_beam
    self.is_in_beam
  end

  def self.remove(ghost)
    # index = Ghost.all.find_index do |gh|
    #   gh.id == ghost.id
    # end

    # Ghost.all.slice!(index)

    Ghost.all = Ghost.all.filter { |g| g.id != ghost.id}
  end

  def calc(tick_count)
    # use different sprite if ghost is on beam
    self.sprite_path = !self.is_in_beam ? "sprites/circle-white.png" : "sprites/circle-gray.png"

    # debug
    self.sprite_path = "sprites/circle-red.png" if !self.is_in_beam && self.has_been_in_beam


    # keep in bounds
    self.y = $HEIGHT if self.y < 0 || self.y > $HEIGHT

    self.toggle_flickering if tick_count % 60 == 0 && rand < 0.5

    self.flicker(tick_count) if self.is_flickering

    # debug
    # args.outputs.labels << [$WIDTH - 200, 100, self.alpha, 255, 255, 255]
  end

  def stick_to_beam(beam)
    self.has_been_in_beam = true if !self.has_been_in_beam # debug

    # center ghost over beam
    self.has_free_will = false
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

  def flicker(tick_count)
    # TODO FIX stop at max 255, min 0
    self.alpha = (255 * Math.sin(tick_count/60 * 0.5 * Math::PI/10))

    # hacky but keeps alpha from going negative
    self.alpha = 20 if self.alpha < 20
  end

  def stop_flickering
    # puts "stop flickering"
    self.is_flickering = false
    self.is_invulnerable = false
    self.alpha = 255
  end

  def toggle_flickering
    self.is_flickering ? self.stop_flickering : self.start_flickering
  end

  def start_flickering
    if self.has_free_will
      # puts "start flickering"
      self.is_flickering = true
      self.is_invulnerable = true
    end
  end

  def self.flicker_threshold
    @@FLICKER_THRESHOLD
  end

  def self.spawn
    # TODO randomly and flicker in
    x = random_int(20, $WIDTH - 100) # TODO subtract ghost width
    y = random_int(400, $HEIGHT - 100)
    puts "spawning at #{x}, #{y}"
    self.all << Ghost.new(x, y)
  end

  def is_inside_beam?(b)
    return false if !b
    self.rect.intersect_rect?([b.x, b.y, b.w, b.h])
  end

  def serialize
    { x: x, y: y, w: w, h: h, is_flickering: is_flickering,  has_free_will: has_free_will, is_in_beam: is_in_beam, id: id, has_been_in_beam: has_been_in_beam }
  end
end

def random_int(min, max)
    rand(max - min) + min
end