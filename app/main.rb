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

  args.state.player.render_ui(args)

  display_debug(args)



end

def can_spawn_ghost? args
  rand >= 0.8 && args.state.tick_count & 60 == 0 && args.state.ghosts.size < 10
end

# update
def calc args
  handle_input(args)

  if can_spawn_ghost?(args)
    args.state.ghosts << Ghost.spawn
  end

  args.state.player.calc(args)

  # TODO FIX THIS ENTIRE MESS
  # if a ghost is colliding with a beam it's inside the beam and has no free will
  # if the player stops shooting and the pack has space, store the ghosts in the pack
  # if the pack runs out of space and there are still ghosts on the beam, release the ghosts
  # maybe replace player ghosts on beam array with a boolean value on each ghost if they're on the beam

  args.state.ghosts.each do |g|
    # beam always technically exists, but should only exist to ghost if player is shooting
    beam = args.state.player.is_shooting ? args.state.player.beam : nil

    if g.should_be_caught_by_beam?(beam)
      g.get_caught_in_beam
      args.state.player.add_ghost_to_beam(g)
    end

    if !g.has_free_will
      g.stick_to_beam(beam)
    end

    g.calc(args.state.tick_count)
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

def remove_ghost(args, ghost)
  index = args.state.ghosts.find_index do |gh|
    gh.id == ghost.id
  end

  args.state.ghosts.slice!(index)
end

def display_debug args
  y = $HEIGHT
  # Ghost.all.each.with_index(1) do |g, i|
  #   r = g.is_in_beam ? 255 : 0
  #   if g.is_in_beam
  #     args.outputs.borders << [g.x,g.y,g.w,g.h, 255, 0, 0]
  #   end
  #   args.outputs.labels << [10, y, "#{g.id} has free will: #{g.has_free_will}, on beam: ", 0, 0, 0]
  #   args.outputs.labels << [330, y, "#{g.is_in_beam}", r, 0, 0]
  #   y -= 30
  # end

  args.outputs.labels << [$WIDTH - 200, 80, "Disposal: #{args.state.disposal.total_ghosts}", 255, 255, 255]
end

