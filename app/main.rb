require 'app/require.rb'

# GLOBALS
# game dimensions
$WIDTH = 1280
$HEIGHT = 720

def defaults args
  # set initial variables
  args.state.player ||= Player.new
  args.state.ghosts ||= [
    Ghost.new(300,450),
    Ghost.new(700,600),
    Ghost.new(1100,600)
  ]
  args.state.mode ||= :play
end

def render args
  render_play(args) if args.state.mode == :play
end

def render_play(args)
  # background
  args.outputs.sprites << [0, 0, $WIDTH, $HEIGHT, 'sprites/wp4470740-1280x720.jpg']

  # player
  args.outputs.sprites << args.state.player.render
  # args.outputs.solids << [args.state.player.beam.x, args.state.player.beam.y, 8, 300, 0, 0, 255]

  args.state.player.render_ui(args)
end

# update
def calc args
  handle_input(args)
  args.state.ghosts.each { |g| g.calc(args) }
end

def handle_input(args)
  args.state.player.move_right if args.inputs.keyboard.d || args.inputs.keyboard.right
  args.state.player.move_left if args.inputs.keyboard.a || args.inputs.keyboard.left
  args.state.player.shoot(args) if args.inputs.keyboard.space

  # TODO keydown/keyup
end

def tick args
  defaults args
  render args
  calc args
end

