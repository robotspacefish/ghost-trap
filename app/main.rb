require 'app/require.rb'

# Game dimensions
$WIDTH = 1280
$HEIGHT = 720

def defaults args
  # set initial variables
  args.state.player ||= Player.new
  args.state.ghosts ||= initGhosts
  args.state.mode ||= :play
end

def initGhosts
  [
    Ghost.new(300,450),
    Ghost.new(1100,600),
    Ghost.new(700,600)
  ]
end

def render args
  mode = args.state.mode

  render_play(args) if mode == :play
end

def render_play(args)
  # background
  args.outputs.sprites << [0, 0, $WIDTH, $HEIGHT, 'sprites/wp4470740-1280x720.jpg']

  # player
  args.outputs.sprites << args.state.player.draw

  # ghosts
  args.outputs.sprites <<  args.state.ghosts.map { |g| g.draw }
end

# update
def calc args
  handle_input(args)
end

def handle_input(args)
  args.state.player.move_right if args.inputs.keyboard.d || args.inputs.keyboard.right
  args.state.player.move_left if args.inputs.keyboard.a || args.inputs.keyboard.left
end

def tick args
  defaults args
  render args
  calc args
end

