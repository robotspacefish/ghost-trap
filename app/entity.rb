class Entity
  attr_accessor :x, :y, :w, :h, :sprite_path, :flip, :alpha

  def initialize(x, y, w, h, sprite_path, flip)
    @w = w
    @h = h
    @x = x
    @y = y
    @sprite_path = sprite_path
    @flip = flip
    @alpha = 255
  end

  def rect
    [x, y, w, h]
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

  def is_colliding_with?(obj)
    self.rect.intersect_rect?(obj.rect)
  end

  def serialize
    {x: x, y: y, w: w, h: h}
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

end