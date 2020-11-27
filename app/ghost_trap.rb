class GhostTrap
  attr_accessor :grid, :inputs, :state, :outputs

  def initialize
    puts "new game"
  end

  def tick
    defaults
    render
    calc
    process_inputs
  end

  def defaults
    state.player ||= Player.new
    state.disposal ||= Disposal.new
    state.ghosts ||= 5.map { Ghost.spawn }
    state.mode ||= :title
    state.timer ||= 20
    state.score ||= 0
  end

  def calc
    calc_play if state.mode == :play
  end

  def calc_play
    state.timer -= 1 if state.tick_count % 60 == 0

    state.mode = :game_over if is_game_over?

    state.ghosts << Ghost.spawn if can_spawn_ghost?

    # state.disposal.calc(state.player)

    state.player.calc(outputs, state.tick_count)

    state.ghosts.each do |g|
      if state.player.is_shooting &&
        g.has_free_will &&
        g.should_be_caught_by_beam?(state.player.beam) &&
        state.player.can_fit_all_beam_ghosts_in_pack?

          g.get_caught_in_beam
          state.player.add_ghost_to_beam(g)

      end

      g.stick_to_beam(state.player.beam) if !g.has_free_will

      g.calc(state.tick_count)

    end

  end

  def can_spawn_ghost?
    rand >= 0.8 && state.tick_count & 60 == 0 && state.ghosts.size < MAX_GHOSTS
  end

  def is_game_over?
    state.timer <= 0
  end

  def add_score(score_to_add)
    state.score += score_to_add
  end

  def remove_ghost(ghost)
    index = state.ghosts.find_index do |gh|
      gh.id == ghost.id
    end

    state.ghosts.slice!(index)
  end

  def process_inputs
    if state.mode == :title && inputs.keyboard.key_down.space
      # TODO clear keydown/key press
      state.mode = :play
    end


    if state.mode == :play
      state.player.stop_moving if !inputs.keyboard.d || !inputs.keyboard.right || !inputs.keyboard.a || !inputs.keyboard.left
      state.player.move_right if inputs.keyboard.d || inputs.keyboard.right
      state.player.move_left if inputs.keyboard.a || inputs.keyboard.left


      # TODO keydown/keyup
      #TODO if !self.can_shoot? make sound when space is pressed
      state.player.is_shooting = inputs.keyboard.space  ? true : false

      state.player.dispose_of_ghosts(state.disposal) if inputs.keyboard.key_down.e
    end

  end

  def render
    render_title if state.mode == :title
    render_play if state.mode == :play
    render_game_over if state.mode == :game_over
  end

  def render_title
    outputs.solids << [0, 0, $WIDTH, $HEIGHT, 0, 0, 0]

    outputs.sprites << [0, 0, $WIDTH, $HEIGHT, "sprites/title-screen.png"]

    outputs.labels << [grid.w.half - 120, 100, "Press [SPACEBAR] to Begin", 255, 255, 255]
  end

  def render_play
    # background
    outputs.sprites << [0, 0, $WIDTH, $HEIGHT, 'sprites/bg.png']

    # ghost disposal
    outputs.sprites << state.disposal.render
    outputs.labels << [600, 311, state.disposal.total_ghosts, 255, 255, 255]

    # ghosts
    outputs.sprites <<  state.ghosts.map { |g| g.render }

    # player
    outputs.sprites << state.player.render

    # hydrant
    outputs.sprites << [1124, 32, 133, 278, 'sprites/hydrant.png']

    state.player.render_beam_power(outputs)

    render_timer

    # display combo, if there is one, & if player can catch ghosts
    if state.player.space_in_pack?
      total_ghosts_on_beam = state.player.total_ghosts_on_beam
      combo_sprite = nil

      if total_ghosts_on_beam > 1
        combo_sprite = "sprites/#{total_ghosts_on_beam}x.png"
        outputs.sprites << [1010, 670, 49, 42, combo_sprite]
        outputs.sprites << [1070, 670, 183, 43, "sprites/combo.png"]
      end
    end

    # if pack is full, show 'empty pack!' text
    if !state.player.space_in_pack?
      outputs.sprites << [980, 660, 270, 51, "sprites/empty-pack.png"]
    end

    # display score
    outputs.sprites << create_sprite_nums(state.score, 10, 680, 's')
  end

  def render_timer
    timer_str = state.timer.to_s
    x = grid.w.half - 60
    y = grid.h - 120

    outputs.sprites << create_sprite_nums(state.timer, x, y)

  end

  def render_game_over
    outputs.solids << [0, 0, $WIDTH, $HEIGHT, 0, 0, 0]

    outputs.labels << [ grid.w.half - 40, grid.h - 200, "GAME OVER", 255, 255, 255]

    outputs.labels << [grid.w.half - 100, grid.h.half + 20, "You disposed of #{state.disposal.total_ghosts} ghosts", 255, 255, 255]

    outputs.labels << [grid.w.half - 100, grid.h.half - 20, "Score:  #{state.score}", 255, 255, 255]
  end

  def play_sound(sound)
    puts sound
    outputs.sounds << sound
  end

end