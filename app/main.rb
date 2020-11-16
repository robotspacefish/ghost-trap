require 'app/require.rb'

# GLOBALS
# game dimensions
$WIDTH = 1280
$HEIGHT = 720

def defaults args
  # set initial variables
  args.state.player ||= Player.new
  args.state.disposal ||= Disposal.new(args.state.player.y - 30)
  args.state.ghosts ||= []
  args.state.mode ||= :play
end

def render args
  render_play(args) if args.state.mode == :play
end

def render_play(args)
  # background
  args.outputs.sprites << [0, 0, $WIDTH, $HEIGHT, 'sprites/wp4470740-1280x720.jpg']

  # ghost disposal
  args.outputs.sprites << args.state.disposal.render

  # ghosts
  args.outputs.sprites <<  args.state.ghosts.map { |g| g.render }

  # player
  args.outputs.sprites << args.state.player.render
  # args.outputs.solids << [args.state.player.beam.x, args.state.player.beam.y, 8, 300, 0, 0, 255]

  args.state.player.render_ui(args)

  # debug
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

def can_spawn_ghost? args
  rand >= 0.8 && args.state.tick_count & 60 == 0 && args.state.ghosts.size < 10
end

# update
def calc args
  handle_input(args)

  # spawn ghost
  args.state.ghosts << Ghost.spawn if can_spawn_ghost?(args)

  args.state.player.calc(args)

  args.state.ghosts.each do |g|
    beam = args.state.player.is_shooting ? args.state.player.beam : nil
    g.calc(args, beam)

    if !g.has_free_will && !g.is_in_beam
      g.is_in_beam = true
      args.state.player.add_ghost_to_beam(g)
    elsif g.has_free_will && g.is_in_beam
      g.is_in_beam = false
      args.state.player.remove_ghost_from_beam(g)
    end
  end
end

def handle_input(args)
  args.state.player.move_right if args.inputs.keyboard.d || args.inputs.keyboard.right
  args.state.player.move_left if args.inputs.keyboard.a || args.inputs.keyboard.left


  # TODO keydown/keyup
  args.state.player.is_shooting = args.inputs.keyboard.space  ? true : false

  args.state.player.dispose_of_ghosts(args.state.disposal) if args.inputs.keyboard.key_down.e

end

def tick args
  defaults args
  render args
  calc args
end

def render_debug args
  args.outputs.labels << [10, $HEIGHT, "Tick Count: #{args.state.tick_count}", 255, 255, 255]

end

