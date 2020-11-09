class Entity
  attr_accessor :x, :y, :w, :h, :sprite_path, :flip, :alpha
  @@all = []

  def initialize(x, y, w, h, sprite_path, flip)
    @w = w
    @h = h
    @x = x
    @y = y
    @sprite_path = sprite_path
    @flip = flip
    @alpha = 255
    self.class.all << self
  end

  def self.all
    @@all
  end

  def render
     [
      x, y, w, h, sprite_path,
      0,              # ANGLE
      self.alpha,            # ALPHA
      255,            # RED SATURATION
      255,            # GREEN SATURATION
      255,            # BLUE SATURATION
      0,              # TILE X
      0,              # TILE Y
      self.w,         # TILE W
      self.h,         # TILE H
      self.flip,      # FLIP HORIZONTALLY
      false           # FLIP VERTICALLY
    ]
  end

  # override :serialize and return hash to Class can be persisted to disk in the event of an exception
  def serialize
    { sprite_path: sprite_path, flip: flip }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

end