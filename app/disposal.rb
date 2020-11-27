class Disposal < Entity
  attr_accessor :total_ghosts, :is_open
  # CLOSED = {
  #   sprite_path: 'sprites/closed-canister.png',
  #   w: 97,
  #   h: 152
  # }

  # OPEN = {
  #   sprite_path: 'sprites/open-canister.png',
  #   w: 105,
  #   h: 174
  # }

  def initialize
    super(566, 221, 99, 154, 'sprites/canister.png', false)
    @is_open = false
    @total_ghosts = 0
  end

  def deposit_ghosts(total_to_add)
    self.total_ghosts += total_to_add
  end

  def calc(player)
    self.is_open = self.is_colliding_with?(player)
  end

  def render
    # set sprite based on open status
    # if self.is_open
    #   self.sprite_path = OPEN[:sprite_path]
    #   self.w = OPEN[:w]
    #   self.h = OPEN[:h]
    # else
    #   self.sprite_path = CLOSED[:sprite_path]
    #   self.w = CLOSED[:w]
    #   self.h = CLOSED[:h]
    # end

    super
  end
end