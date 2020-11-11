require 'app/entity.rb'

class Ghost < Entity
  attr_accessor :is_flickering, :is_invulnerable, :has_free_will, :is_in_beam, :id

  @@FLICKER_THRESHOLD = 255/2
  @@ID = 1

  def initialize(x, y)
    super(x, y, 80, 80, "sprites/circle-white.png", false)
    puts "initiating ghost at #{x}, #{y}"
    @is_flickering = false
    @is_invulnerable = false
    @has_free_will = true
    @is_in_beam = false
    @id = @@ID

    @@ID += 1
  end

  def calc(args, beam)
    # keep in bounds
    self.y = $HEIGHT if self.y < 0 || self.y > $HEIGHT

    if beam && self.is_caught_in_beam(beam)
      # center ghost over beam
      self.has_free_will = false
      diff = self.w - beam.w
      self.x = beam.x - diff/2
    else
      self.has_free_will = true

      # keep above y=300
      self.y += self.y >= 300 ? -0.5 : 0.5

      self.wobble if args.state.tick_count % 10 == 0
    end

    self.toggle_flickering if args.state.tick_count % 60 == 0 && rand < 0.5

    self.flicker(args) if self.is_flickering

    # debug
    # args.outputs.labels << [$WIDTH - 200, 100, self.alpha, 255, 255, 255]
  end

  def wobble
    self.x += rand <= 0.5 ? -10 : 10
    self.y += rand >= 0.5 ? -10 : 10
  end

  def flicker(args)
    # TODO FIX stop at max 255, min 0
    self.alpha = (255 * Math.sin(args.state.tick_count/60 * 0.5 * Math::PI/10))

    # hacky but keeps alpha from going negative
    self.alpha = 20 if self.alpha < 20
  end

  def stop_flickering
    puts "stop flickering"
    self.is_flickering = false
    self.is_invulnerable = false
    self.alpha = 255
  end

  def toggle_flickering
    self.is_flickering ? self.stop_flickering : self.start_flickering
  end

  def start_flickering
    if self.has_free_will
      puts "start flickering"
      self.is_flickering = true
      self.is_invulnerable = true
    end
  end

  def self.flicker_threshold
    @@FLICKER_THRESHOLD
  end

  def self.spawn
    # TODO
    # spawn randomly and flicker in
  end

  def is_caught_in_beam(b)
    !self.is_invulnerable && self.rect.intersect_rect?([b.x, b.y, b.w, b.h])
  end

  def serialize
    { x: x, y: y, w: w, h: h, is_flickering: is_flickering,  has_free_will: has_free_will, is_in_beam: is_in_beam, id: id }
  end
end