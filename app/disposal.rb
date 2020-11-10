require 'app/entity.rb'

class Disposal < Entity
  attr_accessor :total_ghosts, :is_open
  def initialize(y)
    super(50, y, 80, 80, 'sprites/hexagon-blue.png', false)
    @is_open = false
    @total_ghosts = 0
  end

  def add_ghost
    self.total_ghosts += 1
  end

  def open
    self.is_open = true
  end

  def close
    self.is_open = false
  end
end