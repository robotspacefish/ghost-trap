class Entity
  attr_accessor :x, :y, :w, :h, :sprite_path, :flip
  @@all = []

  def initialize(x, y, w, h, sprite_path, flip)
    @w = w
    @h = h
    @x = x
    @y = y
    @sprite_path = sprite_path
    @flip = flip
    self.class.all << self
  end

  def self.all
    @@all
  end

  def draw
    [x, y, w, h, sprite_path]
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