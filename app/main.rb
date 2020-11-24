require 'app/require.rb'

# GLOBALS
# game dimensions
$WIDTH = 1280
$HEIGHT = 720
MAX_GHOSTS = 10

def defaults args
  # set initial variables
  args.state.player ||= Player.new
  args.state.disposal ||= Disposal.new
  args.state.ghosts ||= 5.map { Ghost.spawn }
  args.state.mode ||= :title
  args.state.timer ||= 20
end

def render args
  render_title(args) if args.state.mode == :title
  render_play(args) if args.state.mode == :play
  render_game_over(args) if args.state.mode == :game_over
end

def render_title(args)
  args.outputs.solids << [0, 0, $WIDTH, $HEIGHT, 0, 0, 0]
  args.outputs.labels << [ args.grid.w.half - 40, args.grid.h - 200, "GHOST TRAP", 255, 255, 255]
  args.outputs.labels << [args.grid.w.half - 100, args.grid.h.half + 20, "Press [SPACEBAR] to Begin", 255, 255, 255]
end

def render_game_over(args)
  args.outputs.solids << [0, 0, $WIDTH, $HEIGHT, 0, 0, 0]
  args.outputs.labels << [ args.grid.w.half - 40, args.grid.h - 200, "GAME OVER", 255, 255, 255]
  args.outputs.labels << [args.grid.w.half - 100, args.grid.h.half + 20, "You disposed of #{args.state.disposal.total_ghosts} ghosts", 255, 255, 255]

end

def render_play(args)
  # background
  args.outputs.sprites << [0, 0, $WIDTH, $HEIGHT, 'sprites/bg.png']

  # ghost disposal
  args.outputs.sprites << args.state.disposal.render
  args.outputs.labels << [600, 311, args.state.disposal.total_ghosts, 255, 255, 255]

  # ghosts
  args.outputs.sprites <<  args.state.ghosts.map { |g| g.render }

  # player
  args.outputs.sprites << args.state.player.render

  # hydrant
  args.outputs.sprites << [1124, 32, 133, 278, 'sprites/hydrant.png']

  args.state.player.render_ui(args)

  args.outputs.labels  << [ args.grid.w.half, args.grid.h - 40, "time left: #{args.state.timer}" ]

  total_ghosts_on_beam = args.state.player.total_ghosts_on_beam
  combo_sprite = nil

  if total_ghosts_on_beam > 1
    combo_sprite = "sprites/#{args.state.player.total_ghosts_on_beam}x.png"
    args.outputs.sprites << [1010, 670, 49, 42, combo_sprite]
    args.outputs.sprites << [1070, 670, 183, 43, "sprites/combo.png"]
  end
end

def can_spawn_ghost? args
  rand >= 0.8 && args.state.tick_count & 60 == 0 && args.state.ghosts.size < MAX_GHOSTS
end

# update
def calc args
  handle_input(args)

  calc_play(args) if args.state.mode == :play

end

def calc_play args

  args.state.timer -= 1 if args.state.tick_count % 60 == 0
  args.state.mode = :game_over if is_game_over?(args)

  args.state.ghosts << Ghost.spawn if can_spawn_ghost?(args)

  # args.state.disposal.calc(args.state.player)

  args.state.player.calc(args)

  args.state.ghosts.each do |g|
    if (args.state.player.is_shooting) && g.should_be_caught_by_beam?(args.state.player.beam)
      g.get_caught_in_beam
      args.state.player.add_ghost_to_beam(g)
    end

    g.release_from_beam if !args.state.player.is_shooting && g.is_in_beam

    if !g.has_free_will
      g.stick_to_beam(args.state.player.beam)
    end

    g.calc(args.state.tick_count)
  end
end

def handle_input(args)
  if args.state.mode == :title && args.inputs.keyboard.key_down.space
    # TODO clear keydown/key press
    args.state.mode = :play
  end


  if args.state.mode == :play
    args.state.player.stop_moving if !args.inputs.keyboard.d || !args.inputs.keyboard.right || !args.inputs.keyboard.a || !args.inputs.keyboard.left
    args.state.player.move_right if args.inputs.keyboard.d || args.inputs.keyboard.right
    args.state.player.move_left if args.inputs.keyboard.a || args.inputs.keyboard.left


    # TODO keydown/keyup
    args.state.player.is_shooting = args.inputs.keyboard.space  ? true : false

    args.state.player.dispose_of_ghosts(args.state.disposal) if args.inputs.keyboard.key_down.e
  end

end

def tick args
  defaults args
  render args
  calc args
end

def render_debug args
  args.outputs.labels << [10, $HEIGHT, "Tick Count: #{args.state.tick_count}", 255, 255, 255]

end

def remove_ghost(args, ghost)
  index = args.state.ghosts.find_index do |gh|
    gh.id == ghost.id
  end

  args.state.ghosts.slice!(index)
end

def display_debug args
  y = $HEIGHT
  args.state.ghosts.each.with_index(1) do |g, i|
    r = g.is_in_beam ? 255 : 0
    if g.is_in_beam
      args.outputs.borders << [g.x,g.y,g.w,g.h, 255, 0, 0]
    end
    args.outputs.labels << [10, y, "#{g.id} has free will: #{g.has_free_will}, on beam: ", 0, 0, 0]
    args.outputs.labels << [330, y, "#{g.is_in_beam}", r, 0, 0]
    y -= 30
  end

  args.outputs.labels << [$WIDTH - 200, 80, "Disposal: #{args.state.disposal.total_ghosts}", 255, 255, 255]
end

def is_game_over?(args)
  args.state.timer <= 0
end
