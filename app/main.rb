require 'app/require.rb'
require 'app/ghost_trap.rb'

$WIDTH = 1280
$HEIGHT = 720
MAX_GHOSTS = 10
NUMBER_SPRITES = [
  {w: 60, h: 88},
  {w: 32, h: 82},
  {w: 57, h: 86},
  {w: 59, h: 88},
  {w: 86, h: 88},
  {w: 61, h: 88},
  {w: 56, h: 85},
  {w: 64, h: 88},
  {w: 71, h: 88},
  {w: 65, h: 88}
]

$ghost_trap = GhostTrap.new

def tick(args)
  $ghost_trap.grid = args.grid
  $ghost_trap.inputs = args.inputs
  $ghost_trap.state = args.state
  $ghost_trap.outputs = args.outputs
  $ghost_trap.gtk = args.gtk


  $ghost_trap.tick
end

def remove_ghost(ghost)
  $ghost_trap.remove_ghost(ghost)
end

def add_score(total_ghosts)
  # 1 ghost = 10pts
  # each additional ghost on beam = extra 10pts each
  # if ghosts on beam > 5, each additional ghost on beam = extra 20pts each
  points = total_ghosts * 10
  bonus_points = total_ghosts > 5 ? (total_ghosts - 1) * 20 : (total_ghosts - 1) * 10

  $ghost_trap.add_score(points + bonus_points)
end

def play_sound(type)
  sound = "sounds/"

  case type
  when :dispose
    sound += "collect-burst.wav"
  when :shoot
    sound += "science_fiction_electricity_beam_2.ogg"
  when :flicker_in
    sound += "spooky-high.wav"
  when :flicker_out
    sound += "spooky-low.wav"
  when :alarm
    sound += "alarm.wav"
  when :fail
    sound += "hit-3.wav"
  end

  $ghost_trap.play_sfx(sound)
end

def stop_sound(type)
  # case type
  # end
  $ghost_trap.gtk.stop_music
end

def create_sprite_nums(number, x, y, size = nil)
  number_str = number.to_s
  sprites = []
  divide_by =  1
  spacing = 56

  if size == 's'
     divide_by = 3
     spacing -= 30
  end

  number_str.each_char do |ch|
    num = ch.to_i

    w = NUMBER_SPRITES[num][:w] / divide_by
    h = NUMBER_SPRITES[num][:h] / divide_by

    sprites << [ x, y,w, h, "sprites/numbers/#{ch}.png"]
    x += spacing
  end

  sprites
end

def center_text(text, y_offset = 0, r = 255, g = 255, b = 255)
  grid = $ghost_trap.grid
  w, h = $ghost_trap.gtk.calcstringbox(text)

  [grid.w.half - w/2, grid.h.half + y_offset, text , r, g, b]
end