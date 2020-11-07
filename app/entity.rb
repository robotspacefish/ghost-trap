class Entity
  attr_accessor :x, :y, :w, :h
  @@all = []

  def initialize(x, y, w, h)
    @w = w
    @h = h
    @x = x
    @y = y
    self.class.all << self
  end

  def self.all
    @@all
  end

  def draw
    [x, y, w, h, sprite]
  end
end