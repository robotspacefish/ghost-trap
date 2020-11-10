require 'app/entity.rb'

class Ghost < Entity
  attr_accessor :is_flickering, :is_invulnerable, :has_free_will

  @@FLICKER_THRESHOLD = 255/2

  def initialize(x, y)
    super(x, y, 80, 80, "sprites/circle-white.png", false)
    puts "initiating ghost at #{x}, #{y}"
    @is_flickering = false
    @is_invulnerable = false
    @has_free_will = true

  end

  def calc(args, beam)
    self.y = $HEIGHT if self.y < 0

    if self.is_caught_in_beam(beam)
      self.x = beam.x
    else
      self.y -= 0.5
    end
    # self.flicker(args) if self.is_flickering

    # debug
    # args.outputs.labels << [$WIDTH - 200, 100, self.alpha, 255, 255, 255]
  end

  def flicker(args)
    # TODO stop at max 255, min 0
    self.alpha = (255 * Math.sin(args.state.tick_count/60 * 0.5 * Math::PI/5))
  end

  def stop_flickering
    puts "stop flickering"
    self.is_flickering = false
    self.alpha = 255
  end

  def toggle_flickering
    self.is_flickering ? self.stop_flickering : self.start_flickering
  end

  def start_flickering
    puts "start flickering"
    self.is_flickering = true
  end

  def self.flicker_threshold
    @@FLICKER_THRESHOLD
  end

  def self.spawn
    # TODO
    # spawn randomly and flicker in
  end

  def is_caught_in_beam(b)
    # TODO fix y collision - ghosts keep moving if player stops
    (
      (x + w > b.x && x + w < b.x + b.w) ||
      (x > b.x && x < b.x + b.w) ||
      (x < b.x && x + w > b.x + b.w)
    ) && y < b.y + b.h && y > b.y
  end

  # def follow_beam(beam)

  # end
end