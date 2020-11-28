class Disposal < Entity
  attr_accessor :total_ghosts, :is_open, :timer
  CLOSED = {
    sprite_path: 'sprites/closed-canister.png',
    w: 97,
    h: 152
  }

  OPEN = {
    sprite_path: 'sprites/open-canister.png',
    w: 105,
    h: 174
  }

  def initialize
    super(566, 221, 99, 154, 'sprites/canister.png', false)
    @is_open = false
    @total_ghosts = 0
    @timer = 1
  end

  def deposit_ghosts(total_to_add)
    play_sound(:dispose)
    self.is_open = true
    self.total_ghosts += total_to_add
  end

  def calc(tick_count)
    self.timer -=1 if self.is_open
    puts "open" if self.is_open
    self.is_open = false if timer <= 0 && tick_count % 10 == 0
  end

  def open_canister
    self.sprite_path = OPEN[:sprite_path]
    self.w = OPEN[:w]
    self.h = OPEN[:h]
end

  def close_canister
    self.timer = 1
    self.sprite_path = CLOSED[:sprite_path]
    self.w = CLOSED[:w]
    self.h = CLOSED[:h]
  end

  def render
    # set sprite based on open status
    self.is_open ? open_canister : close_canister

    super
  end
end